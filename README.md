docli.sh
--------------------------------------------------------------------

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

---------------------------------------------------------------------

Prerequisites
This is an example of how to list things you need to use the software and how to install them.

npm
npm install npm@latest -g
Installation
