defmodule Worker do
    use GenServer

    ######################### client API ####################

    def start_link(index, followers, followings, serverID) do
        worker_name = index |> Integer.to_string |> String.to_atom
        GenServer.start_link(__MODULE__, {index, followers, followings}, [name: worker_name])
    end

    def start_tweet(worker_name) do
        GenServer.cast(worker_name, {:start_tweet})
    end

    ######################### callbacks ####################

    def init({index, followers, followings, serverID}) do 
        # use the server nodeID to connect this client to server 
        state = %{id: 0, connected: false, followers: [], followings: [], tweets: []}
        
        status = connect_to_server(serverID)
        
        new_state = %{state | id: index, connected: status, followers: followers, followings: followings}
        {:ok, new_state}
    end

    def handle_cast({:start_tweet}, state) do
        # send tweets to server

        Server.send_tweet(state[:id], followers)
    end

    def handle_cast({:receive_tweet}, state) do
        # add the tweets to client's tweets_list and display all the tweets if user check tweets

        Server.send_tweet(state[:id], followers)
    end
    ######################### helper functions ####################
    defp connect_to_server(serverID) do


        # should return status indicting whether it is connected
    end
end