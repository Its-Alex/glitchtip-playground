import os
import sentry_sdk
sentry_sdk.init(os.getenv('GLITCHTIP_PTYHON_DSN'))

division_by_zero = 1 / 0