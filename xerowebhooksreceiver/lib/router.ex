defmodule XeroWebhooksReceiver.Router do
  use Plug.Router

  @signing_key  Application.get_env(:xerowebhooksreceiver, :signing_key)
  @client EliXero.create_client

  plug :match
  plug :dispatch

  post "/webhooks" do
    IO.puts "Received a webhook"
    {:ok, body, conn} = Plug.Conn.read_body(conn)

    headers = conn |> get_req_header("x-xero-signature")

    provided_signature = Enum.at headers, 0

    generated_signature = :crypto.hmac(:sha256, @signing_key, body) |> Base.encode64

    if generated_signature == provided_signature do
      success conn, body
    else
      fail conn
    end    
  end

  defp success(conn, body) do
    IO.puts "Verified the webhook is from Xero. Returning 200\n"

    {:ok, data} = (Poison.decode body, keys: :atoms)

    Task.start_link(fn -> process_event(data) end)

    send_resp(conn, 200, "")
  end

  defp fail(conn) do
    IO.puts "Signature verification has failed. The request may not be from Xero. Returning 401\n"

    send_resp(conn, 401, "")
  end

  defp process_event(data) do
    IO.puts "Processing event"
    Enum.each(data.events, fn(e) -> record_contact_event(e) end)
    IO.puts "\n"    
  end

  defp record_contact_event(event) do
    if event.eventCategory == "CONTACT" do
      contacts = EliXero.CoreApi.Contacts.find @client, event.resourceId
      contact = Enum.at(contacts.'Contacts', 0)
      IO.puts  "Change for contact with name '" <> contact.'Name' <> "'. Change was '" <> event.eventType <>"'" 
    else
      IO.puts "The event was not a contact event. This example webhook receiver only processes contact events. Skipping event"
    end    
  end
end