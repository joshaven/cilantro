# In progress
Specking & creating generators... 
Goal: to be able to run a cilantro command from the command prompt to build a application framework

# Changes for next version 
* Controller-specific Error Catching
* namespace controller method should redefine the namespace not append it: namespace '/one'; namespace '/two' => '/two'
* (may be done, needs specked) Swap Erb with Erubis for template handeling of .erb or .rhtml files (for faster erb processing)

# Considerations
* checkout Beacon: http://github.com/foca/beacon

# General todo's
* the path is ensured to contain the APP_ROOT & lib in many places... dry it up. > search for "$: <<"