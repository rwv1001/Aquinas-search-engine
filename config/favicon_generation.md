# Configuration for rails_real_favicon gem
# This file defines how to generate favicons from the source image

# You can generate favicons by running:
# rails generate favicon

# Source image requirements:
# - Should be at least 260x260 pixels
# - PNG format recommended
# - Square aspect ratio
# - High contrast and simple design work best for small sizes

# Current source: app/assets/images/shield_favicon_source.png (copied from public/Shield2.png)

# After generation, the favicons will be placed in app/assets/images/favicon/
# and the HTML tags in app/views/shared/_favicon.html.erb will be updated

# To regenerate favicons with the Shield2.png:
# 1. rails generate favicon --source_image=app/assets/images/shield_favicon_source.png
# 2. Restart the Rails server
# 3. Clear browser cache to see the new favicon
