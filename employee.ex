defmodule Employee do
  def init(master) do
    IO.puts("Employee #{inspect self()} created, clocking in!")
    send(master, {:clock_in, self()})
    loop(master)
  end

  def fib(0) do 0 end
  def fib(1) do 1 end
  def fib(n) do fib(n-1) + fib(n-2) end

  def loop(master) do
    receive do
      {:request_fib, cust_pid, n} ->
          send(master, {:clock_out, self()})
        #  IO.puts("I received request: #{n} from: #{inspect cust_pid}")
          fib_result = fib(n)
          send(cust_pid, {:deliver_fib, fib_result})
          send(master, {:clock_in, self()})
          loop(master)
    end
  end
end
