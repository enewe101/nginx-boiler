**To start developing:**

1. Clone this repo.
2. Install docker community edition and docker-compose (which are bundled
   together in the same install)
4. Have a look at `dev-cheatsheet.txt` for a guide on starting up and
   managing the development environment.
5. Make a self-signed SSL certificate and configure Chrome to accept that:

		$ bin/mac-setup.sh

5. Start the development server by doing

		$ ./start.sh --dev


**To setup a staging or production environment an Ubuntu machine:**
1. Clone the repo.
2. Make secrets for authentication between services of the app by running

        $ bin/make-env.sh --mode

	Where "mode" should be replaced by "prod" or "stage".  You will need to 
	provide a passphrase.  The secrets will be stored in `.env.gpg`.

3. Note, you must be on the host whose IP resolves from the domain name in 
	PROD_HOST or STAGE_HOST in .env, so that the SSL certificates will
	work (if any).

4. Run the setup script:

        $ bin/ubuntu-setup.sh

4. If you already have an SSL certificate and Diffie-Helman Group, put them
	in /home/$HOST_USER/app/cert.  The certificate should be named
	`fullchain.pem`, the key should be named `privkey.pem`, and the
	diffie-hellman group should be named `dhparam.pem`.

5. Start the server by doing 

        $ ./start.sh --mode

   where "mode" should be replaced with "prod" for production or "stage" for
   staging.  If you have no SSL certificates, add the --no-ssl flag to start
   the server without using SSL.  Once the server is running in no-ssl mode,
   you can use it to obtain certificates.

        $ ./start.sh --mode --no-ssl

6. If you need to obtain certificates, then once the server is running in
   no-ssl, do:

        $ bin/get-cert.sh

    This will use certbot to obtain certificates, will generate a Diffie-Helman
	group, and then will restart the server using SSL.
