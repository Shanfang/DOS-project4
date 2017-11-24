defmodule Coordinator do
    use GenServer

    ######################### client API ####################
    def start_link(num_of_clients) do
        GenServer.start_link(__MODULE__, num_of_clients, [name: :coordinator])        
    end
    
    # timeout is set to be infinity
    def simulate_register_account(coordinator) do
        GenServer.call(coordinator, {:simulate_register_account}, :infinity)
    end
    # init clients using the input parameters
    def simulate_subscribe(coordinator, following_num) do
        # set timeout to be very infinity because the subscription takes long time
        GenServer.call(coordinator, {:simulate_subscribe, following_num}, :infinity)
    end

    def simulate_zipf_distribution(coordinator, limit) do
        GenServer.call(coordinator, {:simulate_zipf_distribution, limit}, :infinity)
    end

    def simulate_query(coordinator) do
        GenServer.call(coordinator, {:simulate_query}, :infinity)
    end

    def simulate_user_connection do
        GenServer.call(coordinator, {:simulate_user_connection}, :infinity)
    end

    ######################### callbacks ####################
    def init(num_of_clients) do
        :random.seed(:os.timestamp)

        # read tweets from a file, these tweets are used by users in the simulation process
        tweet_store = "tweet_store.txt"
                        |> File.read!
                        |> String.split("\n")
                        IO.puts "Finish initializing tweetstore..."
        hashtag_store = "hashtag_store.txt"
                        |> File.read!
                        |> String.split("\n")
                        IO.puts "Finish initializing tweetstore..."
                        
        # start all the users
        user_list = init_users(num_of_clients, [], 0)
        IO.puts "All the users are initiated..."
        :ets.new(:following_table, [:set, :named_table, :protected])
        :ets.new(:follower_table, [:set, :named_table, :protected])
        
        #new_state = %{state | tweet_store : tweet_store, user_list : user_list}
        {:ok, %{tweet_store : tweet_store, hashtag_store : hashtag_store, user_list : user_list}}
    end

    def handle_call ({:simulate_register_account}, _from, state) do
        simulate_register_account(state[:user_list])
        {:reply, :ok, state}
    end

    def handle_call({:simulate_subscribe, following_num}, _from, state) do
        IO.puts "Start simulating subscription..."
        user_list = state[:user_list]
        simulate_subscribe(user_list, following_num)
        IO.puts "Finished subscription..."
        {:reply, :ok, state}
    end

    def handle_call({:simulate_zipf_distribution, limit}, _from, state) do
        popular_users = get_popular_users(limit)
        zipf_distribution_tweet(popular_users)
        {:reply, :ok, state}
    end

    def handle_call({:simulate_query}, _from, state) do
        IO.puts "Start simulating query tweets subscribed to..."
        query_subscription(state[:user_list])
        #subscriptions = query_subscription(state[:user_list])
        #print_tweets(subscriptions)

        IO.puts "Start simulating query tweets by hashtag to..."
        query_by_hashtag(state[:user_list])
        #hashtag_tweets = query_by_hashtag(state[:user_list])
        #print_tweets(hashtag_tweets)

        IO.puts "Start simulating query tweets that mentions this user..."
        query_by_mention(state[:user_list)]
        #mention_tweets = query_by_mention(state[:user_list)]
        #print_tweets(mention_tweets)
        
        {:reply, :ok, state}
    end

    # 5 is not a magic number(this can be set by user), I use this for simplity.
    def handle_call({:simulate_user_connection}, _from, state) do
        simulate_user_connection(state[:user_list], 5)
        {:reply, :ok, state}        
    end

    ######################### helper functions ####################

    defp init_users(num_of_clients, user_list, num) when num < num_of_clients do
        user = num |> Integer.to_string         
        Worker.start_link(user) 
        user_list = [user | user_list]
        init_users(num_of_clients, user_list, num + 1)
    end

    defp init_users(num_of_clients, user_list, num) do
        user_list
    end

    @doc """
    Simulate the process of user registering account.
    """
    defp simulate_register_account(user_list) do
        total_user = len(user_list)
        Enum.each(user_list, fn(user) ->
            user_pid = String.to_atom(user)
            register_status = Worker.register_account(user_pid)
            register_info = user <> " has register status: " <> register_status
            IO.puts register_info
        end)
    end

    @doc """
    Each user randomly choose following_num users to subscribe to.
    There are three case about the randomly generated to_follow_user:
    case1: already in the following list, i.e., this is a duplicate. Generate a new one.
    case2: it is the user itself. Generate a new one.
    case3: a valid to_follow_user. In this case, there are two cases about user subscribing 
    to to_follow_user. 
        i) successful, add it the the user's following list
        ii) failure, generate another user to follow.

    After finish subscription, each user's following list should be
    updated in the ETS following_table table.
    """
    defp simulate_subscribe(user_list, following_num) do
        total_user = len(user_list)
        Enum.each(user_list, fn(user) ->
            followings = subscribe(user, following_num, total_user, [], 0)
            :ets.insert(:following_table, {user, followings})                                    
        end)
    end
 
    defp subscribe(user, following_num, total_user, following_list, count) when count < following_num do      
        to_follow = :rand.uniform(total_user) - 1 |> Integer.to_string
        cond do
            to_follow in following_list -> 
                subscribe(user, following_num, total_user, following_list, count) 
            to_follow == user ->
                subscribe(user, following_num, total_user, following_list, count) 
            true ->
                worker_pid = String.to_atom(user)
                subscribe_status = Worker.subscribe(worker_pid, user, to_follow)                
                case subscribe_status do
                    :ok -> 
                        # update to_follow user's follower list and upate the value in ETS table
                        follower_list = :ets.lookup(:follower_table, to_follow)
                        follower_list = [user | follower_list]
                        :ets.insert(:follower_table, {to_follow, follower_list})

                        # update user's following list
                        following_list = [to_follow | following_list]
                        subscribe(user, following_num, total_user, following_list, count + 1)
                    :error -> 
                        subscribe(user, following_num, total_user, following_list, count)                                        
                end 
                          
        end
    end

    defp subscribe(following_num, total_user, following_list, count) do
        following_list
    end

    @doc """
    Select users whose number of followers is >= limit, which means only select the popular users.
    The criteria of popular or not is set by the parameter limit.
    """
    defp get_popular_users(limit) do
        #select_followers = :ets.fun2ms(fn {username, followers} when length(followers) >= limit -> followers end)
        select_users = :ets.fun2ms(fn {username, followers} when length(followers) >= limit -> username end)
        
        # popular_follower_list refers to all popular users' followers, each user has a popular follower list
        #popular_follower_list = :ets.select(:follower_table, select_followers)
        :ets.select(:follower_table, select_users)       
    end

    @doc """
    Simulate zipf's distribution and only let popular users to send tweets.
    The popular users randomly select tweet from the tweet store and tweet it.
    The number of tweets each user is supposed to send can be configured in the config file,
    here I use default 1.
    """
    defp zipf_distribution_tweet(popular_users) do
        total_user = len(user_list)
        Enum.each(popular_users, fn(user) ->
            tweets = get_tweets(1) # 1 can be change to any number as required            
            
            worker_pid = String.to_atom(user)
            Enum.each(tweets, fn(tweet) -> 
                Worker.send_tweet(worker_pid, tweet)                                
            end)                      
        end)    
    end
 
    # I set num default to 1 in the test, so that it would not take too long time.
    defp get_tweets(num) do
        state[:tweet_store] |> Enum.shuffle |> List.first
    end

    @doc """
    For the following three query types, each randomly select 1 users to simulate query operation.
    The return value is a list of tweets.
    """
    defp query_subscription(user_list) do
        test_user = Enum.random(user_list)
        worker_pid = String.to_atom(test_user)
        Worker.query_tweet(worker_pid, :subscription)
    end

    defp query_by_hashtag(user_list) do
        test_user = Enum.random(user_list)

        # take 3 random hashtags to query
        #topics = Enum.take_random(state[:hashtag_store], 3)
        #topic = state[:hashtag_store] |> Enum.shuffle |> List.first
        topic = Enum.random(state[:hashtag_store])
        worker_pid = String.to_atom(test_user)
        hashtag_query = "#" <> topic
        Worker.query_tweet(worker_pid, hashtag_query)
    end

    defp query_by_mention(user_list) do
        test_user = Enum.random(user_list)

        worker_pid = String.to_atom(test_user)
        mention_query = "@" <> test_user
        Worker.query_tweet(worker_pid, mention_query)
    end

    @doc """
    Randomly take num users and simulate user connecting to the server.
    After successfully connected, the user should get tweets without querying them.
    """
    defp simulate_user_connection(user_list, num) do
        Enum.take_random(user_list, 5) 
            |> Enum.each(fn(user) -> 
                user |> String.to_atom |> Worker.connect end)        
    end
end