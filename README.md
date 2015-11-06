# CSCI4409_Bakers -- Distributed
Having a bit of fun with the bakers algorithm in elixir
This time we're making an effort to distribute the employees and customers
across several nodes.

# How to run this mess
You'll need to compile all three modules, using c "cthulhu.ex" (etc) within iex or something.
Once that's done, you can start it all up with `spawn(Cthulhu, :init, [x, y])` where `x` and `y` are the
number of employees and customers, respectivly, that you want it to start with.

More customers and employees can be added at any time by calling `send(PID_OF_CTHULHU, {:generate_employees, x})`
where `PID_OF_CTHULHU` is the PID of the process that you spawned (you did store it, right...?) and `x` is the number of
employees or customers that you want to generate. (to generate customers, replace `employees` with `customers` in the send command)

