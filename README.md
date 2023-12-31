# docli.sh
--------- -----------------------------------------------------------

Utility that helps to handle the different docker-compose stacks more
easily.


--------------------------------------------------------------------
    Usage:  [COMMAND] ..[OPTIONS] .. [ARGS]

    Manage multiple docker-compose stacks with a single command.

    Options:
     --all                   Apply the command to all groups in the inventory
     --context[=CTX]         Inventory group to apply the command
     --help                  Display this help message and exit
     --version               Output version information and exit
		Note: 'CTX' = stack group or directory
    Commands:
     create --context=CTX    Create a new empty directory with the specified context
	 	Note: 'CTX' = empty directory
     up   --context=CTX       Start Docker Compose stack in the specified context
     down --context=CTX       Stop Docker Compose stack in the specified context
	 	Note: 'CTX' = stack group

     Examples:
     docli create --context=stack_1
     docli up --context=group_2
     docli down --all


### Change permission and check if docli.sh has changed

-----------------------------------------------------------------------
chmod +x docli.sh

### Display this help message and exit
--------------------------------------------------------------------------

./docli.sh --help

### Output version information and exit
--------------------------------------------------------------------------

./docli.sh --version

### Creates a new empty directory. The directory name will be the one passed within the context=.
--------------------------------------------------------------------------

./docli.sh create --context=stack_1

### Passes the “docker-compose up -d” command to the specified context. Can be used with --all.
--------------------------------------------------------------------------

./docli.sh up --all

### Passes the “docker-compose up -d” command to the specified context. Can be used with --context=.
--------------------------------------------------------------------------

./docli.sh up --context=group_3

### Passes the “docker-compose down” command to the
### specified context. Can be used with --all.
--------------------------------------------------------------------------

./docli.sh down --all

### Passes the “docker-compose down” command to the specified context. Can be used with --context=.
--------------------------------------------------------------------------

./docli.sh down --context=group_3


























