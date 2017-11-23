defmodule Worker do
    use GenServer

    ######################### client API ####################

    def start_link(ID) do
        worker_name = ID |> String.to_atom
        GenServer.start_link(__MODULE__, {ID}, [name: worker_name])
    end

    def register_account(worker_name, userID) do
        GenServer.call(worker_name, {:register_account, userID})
    end

    def send_tweet(worker_name, tweet) do
        GenServer.cast(worker_name, {:send_tweet, tweet})
    end

    def subscribe(worker_name, userID, to_followID) do
        GenServer.call(worker_name, {:subscribe, userID, to_followID})
    end

    def retweet(worker_name, tweet) do
        GenServer.cast(worker_name, {:retweet, tweet})
    end

    def query_tweet(worker_name, query) do
        GenServer.call(worker_name, {:query_tweet, query})
    end

    def disconnect(worker_name) do
        GenServer.cast(worker_name, {:disconnect})        
    end
    ######################### callbacks ####################

    def init({ID}) do 
        state = %{userID: ID, connected: false, followers: [], followings: [], tweets: []}   
        {:ok, state}
    end

    @doc """
    Connection API should return status = {userID, connection_status, followers, followings, tweets}
    The first time it is connected, followers, followings, tweets are []
    """
    def handle_call({:register_account, userID}, _from, state) do
        register_status = Server.register_account(userID)
        connected = 
            case register_status do
                :ok ->
                    true
                :duplicate ->
                    false
            end
        #status = Server.register_account(state[:userID])
        #connection_status = elem(status, 1}
        #followers = elem(status, 2}
        #followings = elem(status, 3}
        #tweets = elem(status, 4}
        new_state = %{state | connected: connected, followers: [], followings: [], tweets: []}
        {:reply, register_status, new_state}
    end

    def handle_cast({:send_tweet, tweet}, state) do
        Server.send_tweet(tweet, state[:userID])
        tweets = [tweet | tweets]      
        new_state = %{state | tweets : tweets}        
        {:noreply, new_state}        
    end

    @doc """
    Only add a new follower if the user successfully subscribes to it, i.e., the server returns :ok
    """
    def handle_call({:subscribe, userID, to_followID}, _from, state) do
        subscribe_status = Server.subscribe(to_followID, userID)
        case subscribe_status do
            :ok -> 
                followers = state[:followers]
                follower_list = [to_followID | followers]
                new_state = %{state | followers : follower_list}
            :error ->
                error_info = "Failed to subscribe to " <> to_followID
                IO.puts error_info
        end

        {:reply, subscribe_status, state}
    end

    def handle_cast({:retweet}, state) do
        #tweet = generate_tweet(state[:userID])
        #@@@@@@@@@@@@ randomly choose a follower's tweet and tweet it
        tweet = select_tweet
        Server.re_tweet(tweet, state[:userID])
        tweets = [tweet | tweets]      
        new_state = %{state | tweets : tweets}        
        {:noreply, new_state}        
    end

    def handle_call({:query_tweet, query}) do
        query_result = Server.query_tweet(query, state[:userID])
        {:reply, query_result, state} 
    end

    def handle_info ({:disconnect}) do
        # simulate disconnection
    end
    ######################### helper functions ####################


end