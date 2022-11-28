# SLAM from Scratch

using [this repo](https://github.com/1988kramer/intel_dataset) for the cleaned dataset and data loading method. 

To run code for the project:
- Activate the julia project
- `using Revise, SLAM` 
- To test a function I make sure the parent file is included in `SLAM.jl` and the function is exported for the SLAM module then I just call it from the REPL
    - NOTE: using Revise lets you modify the source code and then make the call again from the REPL 
    - without having to reimport or anything
- `data = read_data()`
- `viz_scans(data)` (not sure if this works because Plots.jl bug with gif creation on mac I think)
- `plot_scan(data[i][2])` will show plot the laser scan for the ith observation with the robot centered at (0,0) on the xy plane