import click


@click.command()
def main():
    """
    Print nebby's packages.

    \b
    Usage: nebby
    """
    logo = \
        r"""
          _      ____  ___   ___   _         ___        ___ 
         | |\ | | |_  | |_) | |_) \ \_/     / / \  __  / / \
         |_| \| |_|__ |_|_) |_|_)  |_|      \_\_/ (_() \_\_/
        """

    click.secho(logo, fg='blue', bold=True)

    click.echo('[++] OSINT Tools')

    click.echo('\n')

    click.echo('[+] Usernames')
    click.echo('maigret - collect a dossier by username only')
    click.echo('sherlock - hunt down social media accounts by username across social networks')
    click.echo('quidam - extract instagram, twitter, and github information by username\ncd /nebby/clones/quidam')
    click.echo('blackbird - search for accounts by username\ncd /nebby/clones/blackbird')

    click.echo('\n')

    click.echo('[+] Email')
    click.echo('holehe - check if email is used on variety of sites. return useful information')

    click.echo('\n')

    click.echo('[+] Phone Number')
    click.echo('ignorant - check if a phone number is used on different sites like snapchat and instagram')

    click.echo('\n')

    click.echo('[+] Site Specific')
    click.echo('nqntnqnqmb - retrieve information on LinkedIn profiles and companies COOKIE REQUIRED!')
    click.echo('crosslinked - LinkedIn enumeration tool that uses search engine scraping. No API key or login needed.')
    click.echo('toutatis - extract information from instagram accounts')
    click.echo('gitfive - OSINT tool to investigate GitHub profiles')
    click.echo('ghunt - an offensive Google framework focused on OSINT COOKIE REQUIRED!')
    click.echo('snscrape - a social networking service scraper in python')
    click.echo('masto - an OSINT tool written in python to gather intelligence on Mastodon users and instances')

    click.echo('\n')

    click.echo('[+] Swiss Army Knife')
    click.echo('photon - incredibly fast crawler designed for OSINT')
    click.echo('sn0int - semi-automatic OSINT framework and package manager')

    click.echo('\n')

    click.echo('[+] Other')
    click.echo('onionsearch - search on .onion urls')

    click.echo('\n')

    click.echo('[++] Recon Tools')

    click.echo('\n')

    click.echo('[+] Standard Tools')

    click.echo('\n')

    click.echo(f'subfinder - fast passive subdomain enumeration tool')
    click.echo('dnsx - multi-purpose DNS toolkit designed for running various probes through the retryabledns library')
    click.echo('httpx - multi-purpose HTTP toolkit that allows running multiple probes using the retryablehttp library')
    click.echo('naabu - port scanning tool to enumerate valid ports for hosts in a fast and reliable manner')
    click.echo('fingerprintx - similar to httpx that also supports fingerprinting services like'
               '\nRDP, SSH, MySQL, PostgreSQL, Kafka, etc. fingerprintx can be used alongside port scanners like Naabu to fingerprint a set of ports identified during a port scan')
    click.echo('katana - crawling and spidering framework by URL')
    click.echo('dnstwist - domain name permutation engine for detecting homograph phishing attacks, typo squatting, and brand impersonation')

    click.echo('\n')

    click.echo('[+] Secrets')
    click.echo('trufflehog - crawling numerous sources for secrets')
    click.echo('noseyparker - finds secrets and sensitive information in textual data. target text, git, Github.')

    click.echo('\n')

    click.echo('[+] Cloud')
    click.echo('awsrecon - a tool for reconnoitering AWS cloud environments')
    click.echo('cloudlist - is a multi-cloud tool for getting Assets from Cloud Providers')

    click.echo('\n')

    click.echo('[+] Other')
    click.echo('lemmeknow - identify mysterious text or analyze strings from captured network packets or anything')
    click.echo('ares - text decoder similar to lemmeknow')
    click.echo('alterx - fast and customizable subdomain wordlist generator using DSL')
    click.echo('pyWhat - identify anything. lets you identify emails, IP addresses, and more. accepts pcap or text.')


if __name__ == '__main__':
    main()
