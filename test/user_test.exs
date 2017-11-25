defmodule UserTest do
    use ExUnit.Case
    doctest User
  
    setup do
      {:ok,user_pid} = User.start_link
      {:ok,user: user_pid}
    end
    
end