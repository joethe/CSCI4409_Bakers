# CSCI4409_Bakers -- Distributed
Having a bit of fun with the bakers algorithm in elixir
This time we're making an effort to distribute the employees and customers
ross several nodes.

# Setting up nodes
Run: `iex --sname node --cookie frogs --erl "-kernel inet_dist_listen_min 60001 inet_dist_listen_max 60100"`
replacing the sname and cookie with appropriate values.

Following this, you can connect the nodes together using `Node.connect :sname@hostname`
replacing `sname` and `hostname` as appropriate.

# How to run this mess
You'll need to compile all three modules, using c "cthulhu.ex" (etc) within iex or something.
Once that's done, you can start it all up with `spawn(Cthulhu, :init, [x, y, z])` where `x` and `y` are the
number of employees and customers, respectivly, that you want it to start with and `z` is a list of the nodes you want to use
initially.

# Adding Nodes
Nodes can be added at any time, so long as they are connected.
Simply use `send(pid, {:add_node, :sname@hostname})`
replacing `pid` with the PID of your cthulhu process, and `sname` and `hostname` to match the node you want to add.

Nodes will be used when adding new employees and customers. New employees and customers are distributed across all nodes available at their
creation.


# Adding employees and customers
More customers and employees can be added at any time by calling `send(PID_OF_CTHULHU, {:generate_employees, x})`
where `PID_OF_CTHULHU` is the PID of the process that you spawned (you did store it, right...?) and `x` is the number of
employees or customers that you want to generate. (to generate customers, replace `employees` with `customers` in the send command)

