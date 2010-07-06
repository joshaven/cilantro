# In progress
Specking & creating generators... 

* Cleanup generator script... currently you have to be in your project folder and then you run 'cilantro generate'  
  Should support 'cilantro generate project_name'
* Ensure that the generated project runs by its self and does something useful...

# Changes for next version 
* Controller-specific Error Catching
* Swap Erb with Erubis for template handling of .erb or .rhtml files - for faster erb processing. (May be done, needs specked)

# Considerations
* checkout Beacon: http://github.com/foca/beacon

# General todo's
* the path is ensured to contain the APP_ROOT & lib in many places... dry it up. > search for "$: <<"