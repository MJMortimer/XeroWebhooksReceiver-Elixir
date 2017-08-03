# Xero Webhooks Receiver

This sample application demonstrates how to receive webhooks from Xero:

1. Accept a POST request from Xero
2. Verify the payload signature
3. Start an async task to process the webhook, retrieving the names of contacts in contact events, and printing them out
4. Respond with the correct HTTP status code

# Running the application

## Prerequisites
- A private application connected to a Xero Organisation, to generate webhook events (https://app.xero.com/Application/)
- A subscription for your app subscribed to contact events (https://developer.xero.com/myapps)
- Elixir for your desired platform (https://elixir-lang.org/install.html)
- ngrok, to tunnel network traffic to localhost (https://ngrok.com/). You'll need to know the directory it's unzipped in later

Once you've sorted out the prerequisites, clone/download this repo and you're good to get started. 

## Running the server

### Set up the config
You'll need to set up two sections in a config file named `xero_webhooks_receiver_config.exs` in the `xerowebhooksreceiver/config` directory before mix can compile the solution.  
Your `xero_webhooks_receiver_config.exs` config will need to look like this (with the appropriate substituted values): 

```
use Mix.Config  

config :xerowebhooksreceiver,  
  signing_key: "YOUR SIGNING KEY"  
  
config :elixero,
  private_key_path: "path/to/privatekey.pem",
  consumer_key: "YOUR CONSUMER KEY",
  consumer_secret: "YOUR CONSUMER SECRET",
  app_type: :private
```

**What are these config sections used for?**

1. The `:xerowebhooksreceiver` section  
This section of the config file is used to store your signing key found in the developer portal when setting up your webhook subscription.  
The signing key is used to sign the request body of a received webhook to validate that the webhook was sent by Xero.

2. The `:elixero` section  
This section of the config is used to initialise an EliXero (https://github.com/MJMortimer/elixero) client. The client is used to retrieve the details of contacts associated with the events in the received webhooks.  
**Note:** This example webhook receiver only works with private applications. This is due to partner applications requiring user interaction when to organisations and I want to keep this super simple.  

### Start the local server
With you config file complete and included in the correct directory, you're ready to pull in dependencies, compile, and run the application.

1. Using a command line console move to the `xerowebhooksreceiver` directory.
2. Execute `mix do deps.get, compile`. You should see all of the dependencies being retrieved and the application succesfully compile.
3. Execute `mix run --no-halt`. This will run the application and start a local server

### Make the local server accessible from Xero

Currently you'll have a sevrer running on localhost:5000 which is not accessible to the public internet, and thus, cannot receive webhooks from Xero.  
To allow Xero to access your local server, we'll be using ngrok to produce a publicly accessible URL tunneled to your local server.

1. Open a command line tool console in the directory where you've downloaded and unzipped ngrok.
2. Execute `./ngrok http --bind-tls=true 5000`. Ngrok will provide you with a https URL (e.g. https://daaf38b6.ngrok.io).
3. Set your subscription's webhook delivery URL to {ngrok_address}**/webhooks** (e.g. https://daaf38b6.ngrok.io/webhooks) in the [developer portal](https://developer.xero.com/myapps/webhooks).

