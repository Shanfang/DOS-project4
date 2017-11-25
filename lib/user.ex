defmodule User do
    use GenServer
    ######################### client API ####################

    def start_link(userID) do
        GenServer.start_link(__MODULE__, userID, name: via_tuple(userID))
    end

    defp via_tuple(userID) do
        {:via, :gproc, {:n, :l, {:userPool, userID}}}
    end

    def add_tweet(userID, tweet) do
        GenServer.cast(via_tuple(userID), {:add_tweet, tweet})
    end
    
    def get_tweets(userID) do
    GenServer.call(via_tuple(userID), :get_tweets)
    end

    def register_account(workerID, userID) do
        GenServer.call(via_tuple(workerID), {:register_account, userID})
    end

    def send_tweet(workerID, tweet) do
        GenServer.cast(via_tuple(workerID), {:send_tweet, tweet})
    end

    def query_tweet(workerID, query) do
        GenServer.call(via_tuple(workerID), {:query_tweet, query})
    end
    ######################### callbacks ####################

    def init(userID) do
        state = %{userID: "", connected: false, followers: [], followings: [], tweets: []}   
        #new_state = %{state | userID: userID}
        {:ok, state}  
    end

    def handle_cast({:add_tweet, tweet}, state) do
        tweets = state[:tweets]
        {:noreply, %{state | tweets: [tweet | tweets]}}
    end

    def handle_call(:get_tweets, _from, state) do
    {:reply, state[:tweets], state}
    end

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
        new_state = %{state | userID: userID, connected: connected}
        {:reply, register_status, new_state}
    end

    def handle_cast({:send_tweet, tweet}, state) do
        Server.send_tweet(tweet, state[:userID])
        tweets = [tweet | state[:tweets]]      
        new_state = %{state | tweets: tweets}        
        {:noreply, new_state}        
    end

    def handle_call({:query_tweet, query}, _from, state) do
        query_result = Server.query_tweet(query, state[:userID])
        print_tweets(query_result)
        {:reply, query_result, state} 
    end

    ######################### helper functions ####################

    defp print_tweets(tweets) do
        Enum.each(tweets, fn(tweet) -> 
            IO. puts tweet
        end)
    end
end