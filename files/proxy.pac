function FindProxyForURL(url, host) {
    // alert(host + ' is_india: ' + localHostOrDomainIs(host, "commcarehq-india.cloudant.com") + ', is_hq: ' + localHostOrDomainIs(host, "commcarehq.cloudant.com"));
    if ( localHostOrDomainIs(host, "commcarehq.cloudant.com") ) {
        return "SOCKS localhost:5000";
    } else if ( localHostOrDomainIs(host, "commcarehq-india.cloudant.com") ) {
        return "SOCKS localhost:5001";
    } else if ( localHostOrDomainIs(host, "hqproxy0.internal.commcarehq.org") ) {
	return "SOCKS localhost:5000";
    } else {
        return "DIRECT";
    }
}
