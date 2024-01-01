-module(ffi_esgleam).

-export([get_arch/0, get_os/0, do_fetch/1]).

-spec get_arch() -> {ok, x64 | ia32 | arm64 | arm | ppc64} | {err, string()}.
get_arch() ->
    % #TODO: find out how to detect if it's not ia32/x64 for windows :P
    case erlang:system_info(os_type) of
        {unix, _} -> 
            [Arch_Raw, _] = string:split(erlang:system_info(system_architecture), "-"),
            % based on the values that `uname -a` returns
            case Arch_Raw of
                "x86_64" -> 
                    {ok, x64};
                "amd64" ->
                    {ok, x64};
                "i386" ->
                    {ok, ia32};
                "i586" ->
                    {ok, ia32};
                "i686" ->
                    {ok, ia32};
                "aarch64" ->
                    {ok, arm64};
                "armv7l" ->
                    {ok, arm};
                "ppc64" ->
                    {ok, ppc64};
                _ -> {err, Arch_Raw}
                end;
        {win32, _} -> 
            case erlang:system_info(wordsize) of
                4 -> {ok, ia32};
                8 -> {ok, x64}
            end
    end.

% list compiled from erlang otp source
-spec get_os() -> {ok, win32 | darwin | linux | solaris | freebsd | openbsd | dragonfly | irix64 | irix | posix} | {err, atom()}.
get_os() ->
    case erlang:system_info(os_type) of
        {win32, _} -> win32;
        {unix, linux} -> {ok, linux};
        {unix, darwin} -> {ok, darwin};
        {unix, sunos} -> {ok, solaris};
        {unix, sunos4} -> {ok, sunos}; % technically not solaris
        {unix, freebsd} -> {ok, freebsd};
        {unix, openbsd} -> {ok, openbsd};
        {unix, Os} -> {err, Os}
    end.

-spec do_fetch(string()) -> {}.
do_fetch(Url) ->
    inets:start(),
    ssl:start(),
    {ok, {{_, 200, _}, _, Body}} = httpc:request(get, {Url, []}, [], []),
    {ok, Res} = thoas:decode(Body),
    #{<<"dist">> := #{<<"tarball">> := TarUrl}} = Res,
    fetch_tarball(TarUrl)
.

-spec fetch_tarball(string()) -> {}.
fetch_tarball(Url) ->
    io:fwrite("Fetching tarball from: ~s\n", [Url]),
    {ok, {{_, 200, _}, _, Binary}} = httpc:request(get, {Url, []}, [], [{body_format, binary}]),
    ok = erl_tar:extract({binary, Binary}, [compressed, verbose, {cwd, "./priv"}, {files, ["package/bin/esbuild"]}])
.
