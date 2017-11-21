defmodule Worker do
    use GenServer

    ######################### client API ####################

    def start_link(index) do
        worker_name = index |> Integer.to_string |> String.to_atom
        GenServer.start_link(__MODULE__, {index}, [name: worker_name])
    end

    def send_tweet(worker_name) do
        GenServer.cast(worker_name, {:send_tweet})
    end

    def subscribe(worker_name, to_followID) do
        GenServer.cast(worker_name, {:subscribe, to_followID})
    end

    def retweet(worker_name, tweet) do
        GenServer.cast(worker_name, {:retweet, tweet})
    end

    def query_tweet(worker_name) do
        GenServer.call(worker_name, {:query_tweet})
    end

    def disconnect(worker_name) do
        GenServer.cast(worker_name, {:disconnect})        
    end
    ######################### callbacks ####################

    def init({index}) do 
        state = %{userID: "", connected: false, followers: [], followings: [], tweets: []}   
        # connection API should return status = {userID, connection_status, followers, followings, tweets}
        # the first time it is connected, followers, followings, tweets are []
        status = register_account(userID, serverID)
        connection_status = elem(status, 1}
        followers = elem(status, 2}
        followings = elem(status, 3}
        tweets = elem(status, 4}
        new_state = %{state | userID: Integer.to_string(index), connected: connection_status, followers: followers, followings: followings, tweets: tweets}
        {:ok, new_state}
    end

    def handle_cast({:send_tweet}, state) do
        tweet = generate_tweet(state[:userID])

        Server.send_tweet(tweet, state[:userID])
        tweets = [tweet | tweets]      
        new_state = %{state | tweets : tweets}        
        {:ok, new_state}        
    end

    def handle_cast({:subscribe, to_followID}, state) do
        # add the tweets to client's tweets_list and display all the tweets if user check tweets

        Server.subscribe(to_followID, state[:userID], )
        followers = [to_followID | followers]
        new_state = %{state | followers : followers}
        {:ok, new_state}
    end

    def handle_cast({:retweet}, state) do
        #tweet = generate_tweet(state[:userID])
        #@@@@@@@@@@@@ randomly choose a follower's tweet and tweet it
        tweet = select_tweet
        Server.re_tweet(tweet, state[:userID])
        tweets = [tweet | tweets]      
        new_state = %{state | tweets : tweets}        
        {:ok, new_state}        
    end

    def handle_call({:query_tweet}) do
        # randomly select a hashtag/mention/tweet to query???????
        query = generate_query
        Server.query_tweet(query, state[:userID])
        tweets = [tweet | tweets]      
        new_state = %{state | tweets : tweets}        
        {:ok, new_state} 
    end

    def handle_info ({:disconnect}) do
        # simulate disconnection
    end
    ######################### helper functions ####################
    defp register_account(userID, serverID) do

        # should return status indicting whether it is connected
    end

    defp select_tweet do
        # randomly select a tweet for retweet
    end

    defp generate_query do
        # randomly generate a query 
    end
end