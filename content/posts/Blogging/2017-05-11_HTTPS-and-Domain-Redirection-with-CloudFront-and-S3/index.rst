###################################################
HTTPS and Domain Redirection with CloudFront and S3
###################################################

:Authors: Pedro F. H.
:Summary: How set up HTTP redirections with AWS CloudFront and S3.
:Tags: aws, cloudfront, s3, static website


At a certain point it may be desirable to redirect traffic on your static site.
One example is redirecting *HTTP* traffic to an *HTTPS* endpoint once you have
*SSL/TSL* configured.  Another would be redirecting traffic going to your naked
domain (like ``foo.bar``) to a domain starting with ``www`` (``www.foo.bar``),
or vice versa.

This document presents a high level explanation of how to configure *AWS*
*CloudFront* and *S3 Hosted Websites* to redirect requests from *HTTP* to
*HTTPS* endpoints, and from one domain to another.


Details
-------

The following sections assumes that you have prior knowledge in configuring,
and have already setup:

- an *S3 Hosted Website*.
- a *CloudFront* distribution.
- *Route 53* zones and configured DNS records.

There's a wealth of information out there on how to do all the above.  No sense
in repeating it here.


Redirecting HTTP requests to HTTPS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*HTTP* to *HTTPS* redirection can, and should, be handled by *CloudFront*
irrespective of the origin.

Here is a sequence diagram outlining how *HTTP* to *HTTPS* redirection operates
under *CloudFront*.

.. _`Requiring HTTPS for Communication Between Viewers and CloudFront`:
    https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-https-viewers-to-cloudfront.html

.. uml::
  :format: svg
  :class: center-block img-responsive drounin-figure

  skinparam handwritten true
  skinparam monochrome true
  skinparam packageStyle rect
  skinparam sequenceTitleFontSize 18
  skinparam defaultFontName Comic Sans MS
  skinparam shadowing false
  title Redirecting HTTP Requests to HTTPS

  participant Browser as c

  box "www.foo.bar Configuration"
    participant "CF Distribution" as cf_https
    participant "S3 Bucket" as s3_https
  end box

  note right of c
    User makes an HTTP
    (non-HTTPS) request.
  end note
  c -> cf_https : GET http://www.foo.bar/
  note right of cf_https
    CloudFront redirects HTTP
    requests to HTTPS.
  end note
  activate c
    activate cf_https
      cf_https -> c : HTTP 301 to https://www.foo.bar/
    deactivate cf_https

    note right of c
      Browser redirects request over
      HTTPS.
    end note
    c -> cf_https : GET https://www.foo.bar/
    activate cf_https
      cf_https -> s3_https : GET from origin
      activate s3_https
        s3_https -> cf_https : HTTP 200 with data
      deactivate s3_https
      cf_https -> c : HTTP 200 with data
    deactivate cf_https
  deactivate c


This is configured via the *CloudFront console* under *Behaviors*, setting the
*Viewer Protocol Policy* to *Redirect HTTP to HTTPS*.  For details on how to
accomplish this, read the `Requiring HTTPS for Communication Between Viewers
and CloudFront`_ AWS documentation.


Redirecting to a different domain
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*CloudFront* relies on the origin to manage all other forms of redirects.
Turns out that *S3 Hosted Websites* supports a few different forms of
redirection.  In this particular instance we are interested in redirecting all
traffic from one domain to another one.

Let us say we wanted to redirect all traffic going to the ``foo.bar`` domain to
an already existing ``www.foo.bar`` site (redirect from the naked domain to the
``www`` domain).  We would have to set up a second *CloudFront* and *S3 Hosted
Website* configuration for ``foo.bar``.


The following sequence diagram illustrates how this would function with a
*CloudFront* distribution backed by an *S3 Hosted Website* and assumes that
both ``www.foo.bar`` and ``foo.bar`` have been configured as described in the
`Redirecting HTTP requests to HTTPS`_ section above.


.. uml::
  :format: svg
  :class: center-block img-responsive drounin-figure

  skinparam handwritten true
  skinparam monochrome true
  skinparam packageStyle rect
  skinparam sequenceTitleFontSize 18
  skinparam defaultFontName Comic Sans MS
  skinparam shadowing false
  title Redirecting from naked to www domains

  participant Browser as c

  box "www.foo.bar Configuration\n(www domain)"
    participant "CF Distribution" as cf_www
    participant "S3 Bucket" as s3_www
  end box

  box "foo.bar Configuration\n(naked domain)"
    participant "CF Distribution" as cf_naked
    participant "S3 Bucket" as s3_naked
  endbox

  note right of c
    User makes an HTTP request
    with the naked domain.
  end note
  c -> cf_naked : GET http://foo.bar/
  activate c
    activate cf_naked
      note right of cf_naked
        CloudFront fetching from
        S3 on a cache miss.
      end note
      cf_naked -> s3_naked : GET from origin
      activate s3_naked
        note left of s3_naked
          The foo.bar S3 bucket is
          configured to redirect
          all requests to
          https://www.foo.bar/.
        end note
        s3_naked -> cf_naked : HTTP 301 to https://www.foo.bar/
      deactivate s3_naked
      cf_naked -> c : HTTP 301 to https://www.foo.bar/
    deactivate cf_naked

    note right of c
      Browser redirects request over
      HTTPS to the www domain.
    end note
    c -> cf_www : GET https://www.foo.bar/
    activate cf_www
      cf_www -> s3_www : GET from origin
      activate s3_www
        s3_www -> cf_www : HTTP 200 with data
      deactivate s3_www
      cf_www -> c : HTTP 200 with data
    deactivate cf_www
  deactivate c


Setting up an *S3 Website* to redirect traffic to another domain is pretty
straightforward and covered in the `How Do I Redirect Requests to an S3 Bucket
Hosted Website to Another Host`_ AWS documentation.

.. _`How Do I Redirect Requests to an S3 Bucket Hosted Website to Another Host`: 
    http://docs.aws.amazon.com/AmazonS3/latest/user-guide/redirect-website-requests.html

Note that in the sequence diagram above the ``foo.bar`` *S3 Website* is
configured to return an *HTTPS* version of the URL.  This is to avoid a second
round of redirection, from *HTTP* to *HTTPS*, when the browser gets to the
``www.foo.bar`` site.  I only did this for demonstration purposes.  You can
modify it which ever way you would like.

The same could be achieved with *CloudFront* and any web server as the origin
(like Nginx, Apache, or others) instead of *S3 Website*, but if going
serverless is the end goal, the *CloudFront* and *S3 Website* configurations
presented in the document are the way to go.

