defmodule App do
    @doc """
    This application accept number of clients and serverID as input, use this to set up a simulator.
    The simulator simulates clients sending tweets and receiving tweets.
    """
    def main(args) do
        clients = Enum.at(args, 0)
        following_num = Enum.at(args, 1)
        limit = Enum.at(args, 1)
        num_of_clients = String.to_integer(clients)  
        following_num = String.to_integer(following_num)
        loop(num_of_clients, following_num, limit, 1)
    end

    def loop(num_of_clients, following_num, limit, n) when n > 0 do            
        Coordinator.start_link(num_of_clients)
        start_info = num_of_clients <> "users are started in the simulator..." 
        IO.puts start_info

        Coordinator.simulate_register_account(:coordinator)  
        IO.puts "Finished simulating registeration..."

        Coordinator.simulate_subscribe(:coordinator, following_num)  
        IO.puts "Finished simulating subscription..."
        
        Coordinator.simulate_zipf_distribution(:coordinator, limit) 
        zipf_info = "Finished selecting popular users to send " <> limit <> " tweets..."
        IO.puts zipf_info
        
        Coordinator.simulate_query(:coordinator)  
        IO.puts "Finished simulating query tweets..."

        loop(num_of_clients, following_num, limit, n - 1)
    end

    def loop(num_of_clients, following_num, limit, n) do
        :timer.sleep 1000
        loop(num_of_clients, following_num, limit, n)
    end
end
