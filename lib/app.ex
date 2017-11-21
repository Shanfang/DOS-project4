defmodule App do
    @doc """
    This application accept number of clients and serverID as input, use this to set up a simulator.
    The simulator simulates clients sending tweets and receiving tweets.
    """
    def main(args) do
        clients = Enum.at(args, 0)
        #server = Enum.at(args, 1) 
        num_of_clients = String.to_integer(clients)  
        #serverID = String.to_integer(server) # need to further confirm serverID in node id form         
        loop(num_of_clients, 1)
    end

    def loop(num_of_clients, n) when n > 0 do            
        Coordinator.start_link
        IO.puts "Client simulator is started..." 
        Coordinator.start_simulation(:coordinator, num_of_clients, serverID)
        loop(num_of_clients, n - 1)
    end

    def loop(num_of_clients, n) do
        :timer.sleep 1000
        loop(num_of_clients, n)
    end
end
