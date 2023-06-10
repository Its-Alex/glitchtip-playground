#!/usr/bin/env bash
set -e


./scripts/wait-service.sh web 8000 > /dev/null 2>&1

curl -s -X POST http://localhost:8000/rest-auth/registration/ \
   -H "Content-Type: application/json" \
   -d '{
        "email": "user@example.com",
        "password1": "fakepassword",
        "password2": "fakepassword"
    }' > /dev/null || true

curl -s -c cookies.txt -X POST http://localhost:8000/rest-auth/login/ \
   -H "Content-Type: application/json" \
   -d '{
        "email": "user@example.com",
        "password": "fakepassword"
    }' > /dev/null || true

CSRF_TOKEN=$(grep csrf < cookies.txt | awk '{print $NF}')

curl -s -b cookies.txt -X POST http://localhost:8000/api/0/organizations/ \
   -H "Content-Type: application/json" \
   -H "X-CSRFToken: ${CSRF_TOKEN}" \
   -d '{
        "name": "example-org"
    }' > /dev/null || true

curl -s -b cookies.txt -X POST http://localhost:8000/api/0/organizations/example-org/teams/ \
   -H "Content-Type: application/json" \
   -H "X-CSRFToken: ${CSRF_TOKEN}" \
   -d '{
        "slug": "dev"
    }' > /dev/null || true

curl -s -b cookies.txt -X POST http://localhost:8000/api/0/teams/example-org/dev/projects/ \
   -H "Content-Type: application/json" \
   -H "X-CSRFToken: ${CSRF_TOKEN}" \
   -d '{
        "name": "example-python",
        "platform": "python"
    }' > /dev/null || true

DSN_KEY=$(curl -s -b cookies.txt -X GET http://localhost:8000/api/0/projects/example-org/example-python/keys/ \
   -H "Content-Type: application/json" \
   -H "X-CSRFToken: ${CSRF_TOKEN}" | jq -r '.[0].dsn.public')

export GLITCHTIP_PTYHON_DSN="$DSN_KEY"
echo "GlitchTip configured, you can now use DSN: \"$DSN_KEY\""
