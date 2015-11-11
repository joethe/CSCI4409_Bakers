# might use this later to keep more information about nodes, to do a bit of basic load balancing.

#defmodule Node do
#  defstruct name: "defaultNode", employees: 0, customers: 0
#end

defmodule Cthulhu do

  # spawns a new employee. Seperate function allows us to more easily modify how this is done.
  defp spawn_emp() do
    pid = spawn(Employee, :init, [self()])
    IO.puts("New employee: #{inspect pid}")
  end

  # spawns a new customer. Seperate function allows us to more easily modify how this is done.
  defp spawn_cust() do
    pid = spawn(Customer, :init, [self()])
    IO.puts("New customer: #{inspect pid}")
  end

  defp gen_emp(n) do
    # base case, done generating employees
    if(n == 0) do
      IO.puts("Done generating employees")
    else
      #recuse to spawn all employee processes
      spawn_emp()
      gen_emp(n-1)
    end
  end

  defp gen_cust(n) do
    #base case, done generating customers
    if(n == 0) do
      IO.puts("Done generating customers")
    else
      #recurse to spawn new customers
      spawn_cust()
      gen_cust(n-1)
    end
  end

  def chaos_loop(avail_employees, busy_employees, customer_queue, node_list) do
    #IO.puts(" ==== Cthulhu Summary ==== ")
    ##IO.puts("   Available Employees: #{inspect avail_employees}")
    #IO.puts("   Busy Employees: #{inspect busy_employees}")
    #IO.puts("   Customer Queue: #{inspect customer_queue}")
    #IO.puts("   Customer count: #{customer_count}")
    receive do
      {:add_node, node} ->
        IO.puts("adding node #{node}...")
        chaos_loop(avail_employees, busy_employees, customer_queue, node_list ++ [node])

      {:generate_employees, n} -> # Try to generate a few employee processes (n of them)
        IO.puts("Generating #{n} new employees...")
        gen_emp(n)
        chaos_loop(avail_employees, busy_employees, customer_queue, node_list)

      {:generate_customers, n} -> # Try to generate a few customers...
        IO.puts("Generating #{n} new customers...")
        gen_cust(n)
        chaos_loop(avail_employees, busy_employees, customer_queue, node_list)

      {:request_service, cust_pid} -> # Handle a customer request
      #  IO.puts("New customer request from #{inspect cust_pid}")
        if(List.first(avail_employees) == nil) do      pid = spawn(Customer, :init, [self()])
      IO.puts("New customer: #{inspect pid}")
        #  IO.puts("No available employees!!!")
          send(cust_pid, {:deny})
          chaos_loop(avail_employees, busy_employees, customer_queue ++ [cust_pid], node_list)
        else
          [head | _] = avail_employees
          send(cust_pid, {:assign_employee, head}) # tell the customer which employee to contact
          #chaos_loop(List.delete(avail_employees, head), busy_employees ++ [head], customer_queue, customer_count + 1)
          chaos_loop(avail_employees, busy_employees, customer_queue, node_list)
        end

      {:clock_in, emp_pid} ->
      #  IO.puts("Employee #{inspect emp_pid} clocking in... Avail: #{inspect avail_employees} --- Busy: #{inspect busy_employees}")
        if(List.first(customer_queue) != nil) do
          send(List.first(customer_queue), {:assign_employee, emp_pid})
          [_ | tail] = customer_queue
        #  IO.puts("Sending fist customer in queue the address of the recently clocked-in employee")
        #  IO.puts("adding #{inspect emp_pid} to #{inspect avail_employees} and removing from #{inspect busy_employees}")
          chaos_loop(avail_employees ++ [emp_pid], List.delete(busy_employees, emp_pid), tail, node_list)
        else
          chaos_loop(avail_employees ++ [emp_pid], List.delete(busy_employees, emp_pid), customer_queue, node_list)
        end

      {:clock_out, emp_pid} ->
      #  IO.puts("Employee #{inspect emp_pid} clocking out... Avail: #{inspect avail_employees} --- Busy: #{inspect busy_employees}")
        chaos_loop(List.delete(avail_employees, emp_pid), busy_employees ++ [emp_pid], customer_queue, node_list)

      {:summary} ->
        IO.puts(" ==== Cthulhu Summary ==== ")
        IO.puts("   Available Employees: #{inspect avail_employees}")
        IO.puts("   Busy Employees: #{inspect busy_employees}")
        IO.puts("   Customer Queue: #{inspect customer_queue}")
        chaos_loop(avail_employees, busy_employees, customer_queue, node_list)

    end
  end

  # numEmployees -- Number of employees (workers) to start with
  # numCust -- Number of customers (load drivers) to start with
  # nodes -- A list of the snames of nodes to use
  def init(numEmployees, numCust, nodes) do
    IO.puts("Cthulhu INIT Running !")
    :global.register_name(:cthulhu, self())

    # add nodes...
    each(nodes, &(send(self(), {:add_node, &1})))

    send(self(), {:generate_employees, numEmployees})
    send(self(), {:generate_customers, numCust})
    chaos_loop([], [], [], 0)
  end

end
