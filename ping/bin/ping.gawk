function getu(f)
{
    return  gensub(/\[(.+)\..+\]/, "\\1", "g", f);
}

function getPing(line)
{
    return gensub( /.*time=(.*) ms/, "\\1", "g", line) * 1.0;
}

function getSeq(line)
{
    return gensub( /.*icmp_seq=([0-9]*) /, "\\1", "g", line) * 1;
}

function u2h(a)
{
    return strftime("%T", a);
}

function s2hms(s)
{
    return sprintf("%sh %sm %ss", int((s%86400)/3600), int((s%3600)/60) ,s%60)
}

function play_sound(f)
{
	count = 1;
	if (f == "down") count = 4;
	while (count > 0) {
		system("ogg123 ~/src/Linux/ping/sounds/" f ".ogg 2>/dev/null");
		count = count - 1;
	}	
}

function debug()
{
    if (0) printf("%s :  %s/%s/%s ping %d = %s last_resp:%s rct/t:%d/%d (+%d)\n",
	   u2h(utime), last_state, state, steady_resp, ping,
	   resp, last_resp,
	   resp_change_time, utime, utime-resp_change_time);
}

/PING/ {next}

{ 
	seq = getSeq($0);

    if (match($0, "From gateway") ||
	    match($0, "Destination Host Unreachable") ) {
		state = "Internet Down";
		utime = getu($1);
    }
    else if (match($0, "Network is unreachable") ) {
		state = "NIC or gateway Down";
		#utime = last_utime; # no timestamp on this type of line
    } else {
		state = "UP";
		utime = getu($1);
		ping = getPing($0);
		resp = ping<100 ? "fast" : (ping <500 ? "slow" : "deadslow");
		if (last_seq+1 != seq) {
			printf("%s - %d sequence numbers missing (%d -> %d)\n", u2h(utime),seq-last_seq+1,last_seq, seq);
			resp = "dropping";
		}
	}
    
    if (state != last_state) {
		printf("%s - %s",u2h(utime), state);
		if (state == "UP" && last_utime>0) printf(" after %s", s2hms(utime - last_utime));
		printf("\n");
		last_utime = utime;
		play_sound(state=="UP" ? "up":"down");
    }

    if (resp != last_resp) {
		resp_change_time = utime;
		debug();
    } else if ( (utime - resp_change_time) > 2 || (resp=="dropping")) {
		if (resp != steady_resp) {
			printf("%s - internet is %s (%s ms)", u2h(utime), resp, ping);
			if (steady_resp)
				printf(" (was %s)", steady_resp);
			printf("\n");
			play_sound(resp);
			steady_resp = resp;
		}	
	} else {
		debug();
	}
	
    last_state = state;
    last_resp = resp;
	last_seq = seq;
}
