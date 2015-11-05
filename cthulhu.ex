defmodule Cthulhu do

  defp gen_emp(n) do
    # base case, done generating employees
    if(n == 0) do
      IO.puts("Done generating employees")
    else
      #recuse to spawn all employee processes
      pid = spawn(Employee, :init, [self()])
      IO.puts("New employee: #{inspect pid}")
      gen_emp(n-1)
    end
  end

  defp gen_cust(n) do
    #base case, done generating customers
    if(n == 0) do
      IO.puts("Done generating customers")
    else
      #recurse to spawn new customers
      pid = spawn(Customer, :init, [self()])
      IO.puts("New customer: #{inspect pid}")
      gen_cust(n-1)
    end
  end

  def chaos_loop(avail_employees, busy_employees, customer_queue, customer_count) do
    #IO.puts(" ==== Cthulhu Summary ==== ")
    ##IO.puts("   Available Employees: #{inspect avail_employees}")
    #IO.puts("   Busy Employees: #{inspect busy_employees}")
    #IO.puts("   Customer Queue: #{inspect customer_queue}")
    #IO.puts("   Customer count: #{customer_count}")
    receive do
      {:generate_employees, n} -> # Try to generate a few employee processes (n of them)
        IO.puts("Generating #{n} new employees...")
        gen_emp(n)
        chaos_loop(avail_employees, busy_employees, customer_queue, customer_count)

      {:generate_customers, n} -> # Try to generate a few customers...
        IO.puts("Generating #{n} new customers...")
        gen_cust(n)
        chaos_loop(avail_employees, busy_employees, customer_queue, customer_count)

      {:request_service, cust_pid} -> # Handle a customer request
      #  IO.puts("New customer request from #{inspect cust_pid}")
        if(List.first(avail_employees) == nil) do
        #  IO.puts("No available employees!!!")
          send(cust_pid, {:deny})
          chaos_loop(avail_employees, busy_employees, customer_queue ++ [cust_pid], customer_count)
        else
          [head | _] = avail_employees
          send(cust_pid, {:assign_employee, head}) # tell the customer which employee to contact
          #chaos_loop(List.delete(avail_employees, head), busy_employees ++ [head], customer_queue, customer_count + 1)
          chaos_loop(avail_employees, busy_employees, customer_queue, customer_count + 1)
        end

      {:clock_in, emp_pid} ->
      #  IO.puts("Employee #{inspect emp_pid} clocking in... Avail: #{inspect avail_employees} --- Busy: #{inspect busy_employees}")
        if(List.first(customer_queue) != nil) do
          send(List.first(customer_queue), {:assign_employee, emp_pid})
          [_ | tail] = customer_queue
        #  IO.puts("Sending fist customer in queue the address of the recently clocked-in employee")
        #  IO.puts("adding #{inspect emp_pid} to #{inspect avail_employees} and removing from #{inspect busy_employees}")
          chaos_loop(avail_employees ++ [emp_pid], List.delete(busy_employees, emp_pid), tail, customer_count + 1)
        else
          chaos_loop(avail_employees ++ [emp_pid], List.delete(busy_employees, emp_pid), customer_queue, customer_count)
        end

      {:clock_out, emp_pid} ->
      #  IO.puts("Employee #{inspect emp_pid} clocking out... Avail: #{inspect avail_employees} --- Busy: #{inspect busy_employees}")
        chaos_loop(List.delete(avail_employees, emp_pid), busy_employees ++ [emp_pid], customer_queue, customer_count)

      {:summary} ->
        IO.puts(" ==== Cthulhu Summary ==== ")
        IO.puts("   Available Employees: #{inspect avail_employees}")
        IO.puts("   Busy Employees: #{inspect busy_employees}")
        IO.puts("   Customer Queue: #{inspect customer_queue}")
        IO.puts("   Customer count: #{customer_count}")
        chaos_loop(avail_employees, busy_employees, customer_queue, customer_count)



    end
  end

  def init(numEmployees, numCust) do
    IO.puts("Cthulhu INIT Running !")
    send(self(), {:generate_employees, numEmployees})
    send(self(), {:generate_customers, numCust})
    chaos_loop([], [], [], 0)
  end

end
