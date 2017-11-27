defmodule App do
    @doc """
    This application accept number of clients and serverID as input, use this to set up a simulator.
    The simulator simulates clients sending tweets and receiving tweets.
    """
    def main(args) do
        clients = Enum.at(args, 0)
        following_num = Enum.at(args, 1)
        limit = Enum.at(args, 2)
        num_of_clients = String.to_integer(clients)  
        following_num = String.to_integer(following_num)
        loop(num_of_clients, following_num, limit, 1)
    end

    def loop(num_of_clients, following_num, limit, n) when n > 0 do            
        Server.start_link
        IO.puts "Server is up and running..."

        Coordinator.start_link(num_of_clients)
        IO.puts "#{inspect num_of_clients} users are started in the simulator..." 

        Coordinator.simulate_register_account(:coordinator)  
        IO.puts "Finished simulating registeration..."
        IO.puts "================================================================="
        
        Coordinator.simulate_subscribe(:coordinator, following_num)  
        IO.puts "Finished simulating subscription..."
        IO.puts "================================================================="
        
        Coordinator.simulate_zipf_distribution(:coordinator, limit) 
        IO.puts "Finished simuling zipf's distribution..."
        IO.puts "================================================================="
        
        Coordinator.simulate_query(:coordinator)  
        IO.puts "Finished simulating query tweets..."
        IO.puts "=================================================================" 
        
        Coordinator.simulate_user_connection(:coordinator)  
        IO.puts "Finished simulating user connection..."
        IO.puts "================================================================="        

        #loop(num_of_clients, following_num, limit, n - 1)
    end

    def loop(num_of_clients, following_num, limit, n) do
        :timer.sleep 1000
        loop(num_of_clients, following_num, limit, n)
    end
end
