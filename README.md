# sinbeard-blog

Major work in progress. Below are basically a bunch of notes I took

Learning Terraform and AWS

I registered a brand new domain with AWS - sinbeard.net

create a bucket:
`aws s3api create-bucket --bucket <bucket name> --region <region>`

add a policy to a bucket:
`aws s3api put-bucket-policy --bucket MyBucket --policy file://policy.json`

Registered domain on route53. it creates a hosted zone, and terraform seems to create another. shit got weird, so i deleted all the dns records to let terraform control everything

For ACM: DNS validation is slower but doesn't require input from me. this was preferable because i didn't have email set up on the domain i wanted to use. DNS takes a bit to propagate, and the ACM checks the DNS records to make sure i'm able to set them up.

Email validation sends email to five common email address so if those aren't set up, validation is impossible

Terraform also adds some nameservers to the dns records for the domain on route53/aws. I guess those have to be updated manually.

reference:  https://docs.aws.amazon.com/acm/latest/userguide/email-validation.html
            https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html
            https://aws.amazon.com/premiumsupport/knowledge-center/acm-certificate-pending-validation/

I updated my page so www.sinbeard.net worked fine, but for some reason sinbeard.net didn't. A quick google revealed that I could invalidate the Cloudfront files for it, which worked: 
`aws cloudfront create-invalidation --distribution-id <distribution id> --paths "/*"`

