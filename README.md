## Start project in development

    erl -pa $PWD/deps/*/ebin -pa $PWD/ebin -boot _rel/releases/1/erl_api_mock

...then:

    > sync:go().

...to automatically reload erlang code modules as you edit them.