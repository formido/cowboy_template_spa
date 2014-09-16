## Build release in development

    relx -d

## Start project in development

    erl -pa $PWD/deps/*/ebin -pa $PWD/ebin -boot _rel/cowboy_template/releases/1/cowboy_template 

## Auto reload modules as you save them by [installing Sync](https://github.com/rustyio/sync)

    > sync:go().

