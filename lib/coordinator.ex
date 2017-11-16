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
        state = %{clients: %{}, total_tweets: 0}
        {:ok, state}
    end

    def handle_call({:start_simulation, num_of_clients, serverID}, _from, state) do
        init_clients(num_of_clients, serverID)
        IO.puts "Finish initializing clients"
        start_tweeting(num_of_clients)
        IO.puts "Clients start tweeting"
    end

    def handle_cast({:stop_simulator}, state) do
        IO.puts "Simulation is stopped, number of tweets sent is: " <> Integer.to_string(total_tweets)
        #new_state = %{state | total_tweets: total_tweets}
        #{:noreply, new_state}  
        {:noreply, state}      
    end 
    ######################### helper functions ####################
    
    defp init_clients(num_of_clients, serverID) do
        for i <- 0..num_of_clients do
            # worker is a client, it is inited with follwers and followings
            # it is coordinator's work to randomly generate followers and followings for each client(worker)
            

            # implement zipf to generate followers and followings
            followers = []
            followings = []
            Worker.start_link(i, followers, followings, serverID) 
        end
    end

    defp start_tweeting() do
        for i <- 0..num_of_clients do
            client_pid = i |> Integer.to_string |> String.to_atom                    
            Worker.start_tweet(client_pid)
        end
    end
end