PROJECT = example

DEPS = cowboy_trails mixer

dep_mixer   = git https://github.com/inaka/mixer.git  0.1.3
dep_cowboy_trails = git https://github.com/inaka/cowboy-trails 75bf34ba

SHELL_DEPS = sync

dep_sync =  git https://github.com/inaka/sync.git  0.1.3

include erlang.mk

ERLC_OPTS += +'{parse_transform}'

SHELL_OPTS = -name ${PROJECT}@`hostname` -s ${PROJECT} -config rel/sys.config -s sync
