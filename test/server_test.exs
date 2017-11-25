defmodule ServerTest do
    use ExUnit.Case
    doctest Server
  
    setup do
      {:ok,server_pid} = Server.start_link
      {:ok,server: server_pid}
    end
  
    test "registeration" do
      assert Server.register_account("shanfang") == :ok

      assert Server.register_account("dobra") == :ok

      assert Server.register_account("twitter") == :ok
    end
  
    test "subscription" do
      assert Server.register_account("shanfang") == :ok
      
      assert Server.register_account("dobra") == :ok

      assert Server.register_account("twitter") == :ok

      assert Server.subscribe("shanfang", "dobra") == :ok
  
      assert Server.subscribe("shanfang", "twitter") == :ok

      assert Server.subscribe("twitter", "dobra") == :ok
 
      assert Server.subscribe("dobra", "twitter") == :ok
    end
  
    test "send tweet" do
      assert Server.register_account("shanfang") == :ok
      
      assert Server.register_account("dobra") == :ok

      assert Server.register_account("twitter") == :ok

      assert Server.subscribe("shanfang", "dobra") == :ok
  
      assert Server.subscribe("shanfang", "twitter") == :ok

      assert Server.subscribe("twitter", "dobra") == :ok
 
      assert Server.subscribe("dobra", "twitter") == :ok

      assert Server.send_tweet("Twitter engine is cool!", "shanfang") == :ok
     
      assert Server.send_tweet("We are celebrating #thanksgiving by coding all day!", "shanfang") == :ok
      
      assert Server.send_tweet("Dr. @dobra, could you please make the description more clear?", "shanfang") == :ok
      
    end
  
  
    test "query tweet" do
      assert Server.register_account("shanfang") == :ok
      
      assert Server.register_account("dobra") == :ok

      assert Server.register_account("twitter") == :ok

      assert Server.subscribe("shanfang", "dobra") == :ok
  
      assert Server.subscribe("shanfang", "twitter") == :ok

      assert Server.subscribe("twitter", "dobra") == :ok
 
      assert Server.subscribe("dobra", "twitter") == :ok

      assert Server.send_tweet("Twitter engine is cool!", "shanfang") == :ok
     
      assert Server.send_tweet("We are celebrating #thanksgiving by coding all day!", "shanfang") == :ok
      
      assert Server.send_tweet("Dr. @dobra, could you please make the description more clear?", "shanfang") == :ok
      
      assert Server.query_tweet("anything", "twitter") == [ 
                                                            "Dr. @dobra, could you please make the description more clear?",
                                                            "We are celebrating #thanksgiving by coding all day!",
                                                            "Twitter engine is cool!"
                                                          ]
      
      assert Server.query_tweet("#thanksgiving", "twitter") == ["We are celebrating #thanksgiving by coding all day!"]
      
      #assert Server.query_tweet("@dobra", "dobra") == ["Dr. @dobra, could you please make the description more clear?"]
    end
    
  end
  