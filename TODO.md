# In progress
Specking & creating generators... 

* Cleanup generator script... currently you have to be in your project folder and then you run 'cilantro generate'  
  Should support 'cilantro generate project_name
* Ensure that the generated project runs by its self and does something useful...

# Changes for next version 
* Controller-specific Error Catching
* namespace controller method should redefine the namespace not append it: namespace '/one'; namespace '/two' => '/two'
* (may be done, needs specked) Swap Erb with Erubis for template handeling of .erb or .rhtml files (for faster erb processing)

# Considerations
* checkout Beacon: http://github.com/foca/beacon

# General todo's
* the path is ensured to contain the APP_ROOT & lib in many places... dry it up. > search for "$: <<"