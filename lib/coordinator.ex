defmodule Coordinator do
    use GenServer
@doc """
    Need to implement zifp distribution in order to simulate a real scenario, i.e., only few 
    people hava large number of followers, while most of clients have few or no follwers at all.
"""

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

    ######################### callbacks ####################
    def init(num_of_clients) do
        :random.seed(:os.timestamp)

        # read tweets from a file, these tweets are used by users in the simulation process
        tweet_store = "tweet_store.txt"
        |> File.read!
        |> String.split("\n")
        IO.puts "Finish initializing tweetstore..."

        # start all the users
        user_list = init_users(num_of_clients, [], 0)
        IO.puts "All the users are initiated..."
        :ets.new(:following_table, [:set, :named_table, :protected])
        :ets.new(:follower_table, [:set, :named_table, :protected])
        
        #new_state = %{state | tweet_store : tweet_store, user_list : user_list}
        {:ok, %{tweet_store : tweet_store, user_list : user_list}}
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

    def handle_cast({:stop_simulator}, state) do
        IO.puts "Simulation is stopped, number of tweets sent is: " <> Integer.to_string(total_tweets)
        {:noreply, state}      
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
    Simulate the process of user registering account
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

    defp start_tweet(num_of_clients) do
        for i <- 0..(num_of_clients - 1) do
            user_pid = i |> Integer.to_string |> String.to_atom                    
            Worker.start_tweet(user_pid)
        end
    end
end