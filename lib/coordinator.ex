defmodule Coordinator do
    use GenServer
@doc """
   
->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->->
    Need to implement zifp distribution in order to simulate a real scenario, i.e., only few 
    people hava large number of followers, while most of clients have few or no follwers at all.
"""

    ######################### client API ####################
    def start_link do
        GenServer.start_link(__MODULE__, %{}, [name: :coordinator])
    end

    # init clients using the input parameters
    def start_simulation(coordinator, num_of_clients) do
        GenServer.call(coordinator, {:start_simulation, num_of_clients, serverID}, 30000000)
        # set timeout to be very large number, in case init process could not finish
    end

    @doc """
    ????? there is no need to stop the simulator, just let it run forever, like what we did in bitcoin mining???
    def stop_simulator(coordinator) do
        GenServer.cast(coordinator, {:stop_routing})
    end
    """
    ######################### callbacks ####################
    def init(%{}) do
        state = %{user_list: []}
        {:ok, state}
    end

    def handle_call({:start_simulation, num_of_clients, serverID}, _from, state) do
        user_list = state[:user_list]
        user_list = init_users(num_of_clients, serverID, user_list, 0)
        IO.puts "Finish initializing clients"

        start_tweet(num_of_clients)
        IO.puts "Clients start tweeting"
        new_state = {state | user_list : user_list}
        {:reply, :ok, new_state}
    end

    def handle_cast({:stop_simulator}, state) do
        IO.puts "Simulation is stopped, number of tweets sent is: " <> Integer.to_string(total_tweets)
        {:noreply, state}      
    end 
    ######################### helper functions ####################

    def init_users(num_of_clients, serverID, user_list, num) when num < num_of_clients do
        Worker.start_link(num) 
        user_list = [Integer.to_string(num) | user_list]
        init_users(num_of_clients, serverID, user_list, num + 1)
    end

    def init_users(num_of_clients, serverID, user_list, num) do
        user_list
    end

    defp start_tweet(num_of_clients) do
        for i <- 0..(num_of_clients - 1) do
            user_pid = i |> Integer.to_string |> String.to_atom                    
            Worker.start_tweet(user_pid)
        end
    end
end