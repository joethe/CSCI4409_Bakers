defmodule Customer do

  def loop(dark_lord, employee_pid) do
    receive do
      {:deny} ->
        loop(dark_lord, nil)

      {:assign_employee, emp_pid} ->
        #IO.puts("Got assigned employee: #{inspect emp_pid}")
        rand = :random.uniform(45)
        send(emp_pid, {:request_fib, self(), rand})
        loop(dark_lord, emp_pid)

      {:deliver_fib, fib} ->
      #  if(emp_pid != employee_pid) do
      #    IO.puts("Wrong employee responded !?!?")
      #  end

        IO.puts("I got my fib~ #{fib}") #print fib and don't loop. Customer "dies"
        Agent.stop(self(), 5000)
    end

    loop(dark_lord, employee_pid)

  end

  def init(dark_lord) do

    IO.puts("Client #{inspect self()} created. Dark lord: #{inspect dark_lord} ... sleeping...")

    :random.seed(:erlang.now)
    :timer.sleep(:random.uniform(20000))

    IO.puts("Client #{inspect self()} awake!")

    send(dark_lord, {:request_service, self()})
    loop(dark_lord, nil)
  end




end
