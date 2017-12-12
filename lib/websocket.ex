defmodule SocketClient do
  @moduledoc false
  require Logger
  alias Phoenix.Channels.GenSocketClient
  @behaviour GenSocketClient

    def start_link(userID) do
        userSocket = userID <> "socket"
        {:ok, socket} = GenSocketClient.start_link(
            __MODULE__,
            Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
            {"ws://localhost:4000/socket/websocket", userID}
            # [],
            # name: via_tuple(userSocket)
            )
        IO.puts "socket process is: #{inspect socket}"
    end
    # defp via_tuple(userID) do
    #     {:via, :gproc, {:n, :l, {:userPool, userID}}}
    # end

    def init({url, userID}) do
        IO.puts "Set up websocket connection to #{inspect url}"
        {:connect, url, [], %{userID: userID}}
    end


    def handle_connected(transport, state) do
        Logger.info("Websocket is connected...")
        GenSocketClient.join(transport, "tweeter")
        {:ok, state}
    end

    def handle_disconnected(reason, state) do
        Logger.error("disconnected: #{inspect reason}")
        Process.send_after(self(), :connect, :timer.seconds(1))
        {:ok, state}
    end


    def handle_joined(topic, _payload, transport, state) do
        Logger.info("Joined the topic #{topic}")
        GenSocketClient.push(transport, "tweeter", "register_account", %{userID: state[:userID]})
        {:ok, state}
    end

    def handle_join_error(topic, payload, _transport, state) do
        Logger.error("join error on the topic #{topic}: #{inspect payload}")
        {:ok, state}
    end


    def handle_channel_closed(topic, payload, _transport, state) do
        Logger.error("disconnected from the topic #{topic}: #{inspect payload}")
        Process.send_after(self(), {:join, topic}, :timer.seconds(1))
        {:ok, state}
    end

   # invoked when a message arrives from server
    def handle_message(topic, event, payload, _transport, state) do
        Logger.warn("message on topic #{topic}: #{event} #{inspect payload}")
        {:ok, state}
    end

    # handle query method, invoked when server replies to a message
    def handle_reply("twitter:query", _ref, payload, _transport, state) do
        Logger.info("query result from server")
        IO.inspect payload
        {:ok, state}
    end

    def handle_reply(topic, _ref, payload, _transport, state) do
        Logger.warn("reply on topic #{topic}: #{inspect payload}")
        {:ok, state}
    end

    def handle_info(:connect, _transport, state) do
        Logger.info("connecting")
        {:connect, state}
    end

    def handle_info({:join, topic}, transport, state) do
        Logger.info("joining the topic #{topic}")
        case GenSocketClient.join(transport, topic) do
            {:error, reason} ->
                Logger.error("error joining the topic #{topic}: #{inspect reason}")
                Process.send_after(self(), {:join, topic}, :timer.seconds(1))
            {:ok, _ref} -> IO.puts "joined again ^_^"
        end
        {:ok, state}
    end

    def handle_info({:register_account, userID}, transport, state) do
        GenSocketClient.push(transport, "tweeter", "register_account", %{userID: userID})
        {:ok, state}
    end
end