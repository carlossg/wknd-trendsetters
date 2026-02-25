#!/usr/bin/env bash
# Import content from https://wknd-trendsetters.site/ into da.live carlossg/wknd-trendsetters
#
# Usage:
#   1. Create a .env file in the project root with DA_TOKEN=<your-token>
#   2. Run: bash tools/import-from-site.sh
#
# Prerequisites: curl, jq

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load token from .env
if [[ -f "$PROJECT_ROOT/.env" ]]; then
  # shellcheck source=/dev/null
  source "$PROJECT_ROOT/.env"
fi

if [[ -z "${DA_TOKEN:-}" ]]; then
  echo "Error: DA_TOKEN not set. Add it to .env or export it." >&2
  exit 1
fi

TARGET_ORG="carlossg"
TARGET_REPO="wknd-trendsetters"
API_BASE="https://admin.da.live"
SITE="https://wknd-trendsetters.site"
AUTH_HEADER="Authorization: Bearer $DA_TOKEN"
TMP_DIR=$(mktemp -d)

trap 'rm -rf "$TMP_DIR"' EXIT

upload_file() {
  local local_path="$1"
  local remote_path="$2"
  local content_type="${3:-application/octet-stream}"

  echo "  Uploading: $remote_path"
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" \
    -X PUT \
    -H "$AUTH_HEADER" \
    -F "data=@$local_path;type=$content_type" \
    "$API_BASE/source/$TARGET_ORG/$TARGET_REPO$remote_path") || status="failed"

  if [[ "$status" == 2* ]]; then
    echo "    OK ($status)"
  else
    echo "    Upload returned: $status" >&2
  fi
}

# ===========================
# Step 1: Download and upload all images
# ===========================
echo "=== Step 1: Importing images ==="

IMAGES=(
  hero-hiphop-dance.avif
  hero-family-vacation.avif
  hero-music-concert.avif
  beach-destination.avif
  concert-crowd.avif
  campus-life.avif
  gaming-tournaments.avif
  mobile-game-character.avif
  fashion-inspiration.avif
  campus-tour.avif
  networking-event.avif
  fundraising-event.avif
  adventure-spots.avif
  avatar-alex.avif
  avatar-taylor.avif
  avatar-jordan.avif
  avatar-morgan.avif
  tab-campus.avif
  tab-staff.avif
  fashion-insights-hero.avif
  gallery-1.avif
  gallery-2.avif
  gallery-3.avif
  gallery-4.avif
  gallery-6.avif
  season-trend-1.avif
  season-trend-2.avif
  season-trend-3.avif
  season-trend-4.avif
  customer-headshot.avif
  celebrities-events.avif
  trending-outfits.avif
  successful-events.avif
  shopping-bag.avif
  people-coffee.avif
  bustling-pub.avif
  cycling-event.avif
  party-vacation.avif
  casual-trend.avif
  party-accessories.avif
  game-characters.avif
  faq-hero.avif
  ace-polo-court-style.avif
  flip-flop-beach-style.avif
  street-style.avif
)

for img in "${IMAGES[@]}"; do
  echo "Downloading: $img"
  if curl -sf -o "$TMP_DIR/$img" "$SITE/images/$img"; then
    upload_file "$TMP_DIR/$img" "/images/$img" "image/avif"
  else
    echo "  Download failed: $img" >&2
  fi
done

# ===========================
# Step 2: Create and upload EDS content pages
# ===========================
echo ""
echo "=== Step 2: Importing content pages ==="

# Image base URL - use absolute URLs so AEM can resolve them
IMG="https://wknd-trendsetters.site/images"

# --- nav.html ---
cat > "$TMP_DIR/nav.html" << 'NAVEOF'
<body>
<header>
  <div>
    <div>
      <p><a href="/">Fashion Blog</a></p>
    </div>
    <div>
      <ul>
        <li><a href="/fashion-trends-young-adults-casual-sport">Trends</a></li>
        <li><a href="/fashion-trends-of-the-season">About</a></li>
        <li><a href="/blog">Blog</a></li>
        <li><a href="/faq">FAQ</a></li>
      </ul>
    </div>
    <div>
      <p><strong><a href="#">Subscribe</a></strong></p>
    </div>
  </div>
</header>
</body>
NAVEOF
upload_file "$TMP_DIR/nav.html" "/nav.html" "text/html"

# --- footer.html ---
cat > "$TMP_DIR/footer.html" << 'FOOTEOF'
<body>
<footer>
  <div>
    <div>
      <p><a href="/">Fashion Blog</a></p>
    </div>
    <div>
      <h4>Trends</h4>
      <ul>
        <li><a href="#">Style</a></li>
        <li><a href="#">Looks</a></li>
        <li><a href="#">Events</a></li>
        <li><a href="#">Brands</a></li>
        <li><a href="#">Tips</a></li>
      </ul>
    </div>
    <div>
      <h4>Inspire</h4>
      <ul>
        <li><a href="#">Stories</a></li>
        <li><a href="#">People</a></li>
        <li><a href="#">Culture</a></li>
        <li><a href="#">Vibes</a></li>
        <li><a href="#">Fun</a></li>
      </ul>
    </div>
    <div>
      <h4>Explore</h4>
      <ul>
        <li><a href="#">Travel</a></li>
        <li><a href="#">Beach</a></li>
        <li><a href="#">Night</a></li>
        <li><a href="#">Sport</a></li>
        <li><a href="#">Chill</a></li>
      </ul>
    </div>
  </div>
</footer>
</body>
FOOTEOF
upload_file "$TMP_DIR/footer.html" "/footer.html" "text/html"

# --- index.html (homepage) ---
cat > "$TMP_DIR/index.html" << 'INDEXEOF'
<body>
<header>
  <div>
    <div>
      <div>
        <p><picture><img src="https://wknd-trendsetters.site/images/hero-hiphop-dance.avif" alt="Hero background"></picture></p>
        <p><picture><img src="https://wknd-trendsetters.site/images/hero-family-vacation.avif" alt="Hero background"></picture></p>
        <p><picture><img src="https://wknd-trendsetters.site/images/hero-music-concert.avif" alt="Hero background"></picture></p>
      </div>
      <div>
        <h1>Fresh looks, bold stories, real life</h1>
        <p>Dive into our latest style adventures—see how young trendsetters own every moment, from courtside to the dance floor.</p>
        <p><strong><a href="/case-studies">See case</a></strong></p>
        <p><em><a href="/fashion-insights">All stories</a></em></p>
      </div>
    </div>
  </div>
</header>
<main>
  <div>
    <h2>Latest articles</h2>
    <p>Fresh looks, bold moves</p>
    <div class="cards">
      <div>
        <div>
          <picture><img src="https://wknd-trendsetters.site/images/hero-hiphop-dance.avif" alt="Tennis style"></picture>
        </div>
        <div>
          <p>Casual Cool · May 12</p>
          <h3><a href="/blog/latest-trends-young-casual-fashion">Tennis style, redefined</a></h3>
        </div>
      </div>
      <div>
        <div>
          <picture><img src="https://wknd-trendsetters.site/images/fundraising-event.avif" alt="Beach vibes"></picture>
        </div>
        <div>
          <p>Beach Vibes · May 10</p>
          <h3><a href="/blog/fashion-trends-young-culture">Sunkissed and effortless</a></h3>
        </div>
      </div>
      <div>
        <div>
          <picture><img src="https://wknd-trendsetters.site/images/hero-family-vacation.avif" alt="Party fits"></picture>
        </div>
        <div>
          <p>Night Out · May 8</p>
          <h3><a href="/blog/fashion-trends-young-style">Party fits that pop</a></h3>
        </div>
      </div>
      <div>
        <div>
          <picture><img src="https://wknd-trendsetters.site/images/mobile-game-character.avif" alt="Sport mode"></picture>
        </div>
        <div>
          <p>Sport Mode · May 5</p>
          <h3><a href="/blog/fashion-blog-post">Game on, style up</a></h3>
        </div>
      </div>
    </div>
  </div>
  <hr>
  <div>
    <div class="tabs">
      <div>
        <div>Alex Rivera</div>
        <div>
          <div class="columns">
            <div>
              <div><picture><img src="https://wknd-trendsetters.site/images/hero-hiphop-dance.avif" alt="Alex Rivera style"></picture></div>
              <div>
                <p>"Wearing new brands makes every day feel like a runway. I love mixing sporty vibes with bold colors—perfect for tennis or a night out!"</p>
                <p><picture><img src="https://wknd-trendsetters.site/images/avatar-alex.avif" alt="Alex Rivera" width="60" height="60"></picture></p>
                <p><strong>Alex Rivera</strong></p>
                <p>Streetwear Enthusiast</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div>
        <div>Taylor Kim</div>
        <div>
          <div class="columns">
            <div>
              <div><picture><img src="https://wknd-trendsetters.site/images/tab-campus.avif" alt="Taylor Kim style"></picture></div>
              <div>
                <p>"Fresh looks, comfy fits—my go-to for beach days and city strolls. These brands keep my style on point and effortless."</p>
                <p><picture><img src="https://wknd-trendsetters.site/images/avatar-taylor.avif" alt="Taylor Kim" width="60" height="60"></picture></p>
                <p><strong>Taylor Kim</strong></p>
                <p>Casual Style Blogger</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div>
        <div>Jordan Ellis</div>
        <div>
          <div class="columns">
            <div>
              <div><picture><img src="https://wknd-trendsetters.site/images/tab-staff.avif" alt="Jordan Ellis style"></picture></div>
              <div>
                <p>"Nothing beats the confidence boost from a killer outfit. I'm always ready for spontaneous adventures in these cool threads."</p>
                <p><picture><img src="https://wknd-trendsetters.site/images/avatar-jordan.avif" alt="Jordan Ellis" width="60" height="60"></picture></p>
                <p><strong>Jordan Ellis</strong></p>
                <p>Trend Spotter</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div>
        <div>Morgan Blake</div>
        <div>
          <div class="columns">
            <div>
              <div><picture><img src="https://wknd-trendsetters.site/images/mobile-game-character.avif" alt="Morgan Blake style"></picture></div>
              <div>
                <p>"From rooftop parties to late-night hangs, these styles turn heads. Fashion should be fun, and this is pure fun!"</p>
                <p><picture><img src="https://wknd-trendsetters.site/images/avatar-morgan.avif" alt="Morgan Blake" width="60" height="60"></picture></p>
                <p><strong>Morgan Blake</strong></p>
                <p>Party Scene Curator</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  <hr>
  <div>
    <div class="accordion">
      <div>
        <div>
          <h2>Got questions? We've got answers.</h2>
          <p>Fashion FAQs, answered fast</p>
        </div>
      </div>
      <div>
        <div>How do I spot the latest trends?</div>
        <div><p>We keep it fresh! Check our weekly trend roundups and street style snaps for what's hot right now.</p></div>
      </div>
      <div>
        <div>Can I share my own outfit pics?</div>
        <div><p>Absolutely! Tag us on socials or use our upload form to get featured in our next style story.</p></div>
      </div>
      <div>
        <div>Where do you find your style inspo?</div>
        <div><p>From city streets to beach parties, we're always on the lookout for bold looks and cool creators.</p></div>
      </div>
      <div>
        <div>How can I join your community?</div>
        <div><p>Sign up for our newsletter or jump into the comments—everyone's welcome to join the fun!</p></div>
      </div>
    </div>
  </div>
  <hr>
  <div>
    <div class="columns">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/networking-event.avif" alt="CTA image"></picture></div>
        <div>
          <h2>Fresh looks, bold stories, real life</h2>
          <p>Dive into our latest case study: see how young trendsetters rock new brands from courtside to the dance floor. Discover the style, the vibe, and the impact—one story at a time.</p>
          <p><strong><a href="/case-studies">See more</a></strong></p>
        </div>
      </div>
    </div>
  </div>
</main>
</body>
INDEXEOF
upload_file "$TMP_DIR/index.html" "/index.html" "text/html"

# --- fashion-insights.html ---
cat > "$TMP_DIR/fashion-insights.html" << 'FIEOF'
<body>
<header>
  <div>
    <div>
      <div><picture><img src="https://wknd-trendsetters.site/images/fashion-insights-hero.avif" alt="Fashion insights hero"></picture></div>
      <div>
        <h1>WKND Trendsetters Blog</h1>
        <p>From tennis courts to neon nights, discover the latest trends, style inspo, and stories from the coolest scenes. Dive into a world where fashion meets fun—your next look starts here.</p>
        <p><strong><a href="#articles">Read now</a></strong></p>
        <p><em><a href="/fashion-trends-of-the-season">See trends</a></em></p>
      </div>
    </div>
  </div>
</header>
<main>
  <div>
    <div class="columns">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/adventure-spots.avif" alt="Featured article"></picture></div>
        <div>
          <p>Featured</p>
          <h2>Fresh looks, bold moves</h2>
          <p>Dive into our latest style adventures—see how young trendsetters own every moment.</p>
          <p><a href="/blog/latest-trends-young-casual-fashion">Read the full article</a></p>
        </div>
      </div>
    </div>
  </div>
  <hr>
  <div>
    <h2>Latest Articles</h2>
    <p>Fresh looks, bold moves</p>
    <div class="cards">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/hero-hiphop-dance.avif" alt="Tennis style"></picture></div>
        <div>
          <p>Casual Cool · May 12</p>
          <h3><a href="/blog/latest-trends-young-casual-fashion">Tennis style, redefined</a></h3>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/fundraising-event.avif" alt="Beach vibes"></picture></div>
        <div>
          <p>Beach Vibes · May 10</p>
          <h3><a href="/blog/fashion-trends-young-culture">Sunkissed and effortless</a></h3>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/hero-family-vacation.avif" alt="Night out"></picture></div>
        <div>
          <p>Night Out · May 8</p>
          <h3><a href="/blog/fashion-trends-young-style">Party fits that pop</a></h3>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/mobile-game-character.avif" alt="Sport mode"></picture></div>
        <div>
          <p>Sport Mode · May 5</p>
          <h3><a href="/blog/fashion-blog-post">Game on, style up</a></h3>
        </div>
      </div>
    </div>
  </div>
  <hr>
  <div>
    <h2>Style in every snapshot</h2>
    <p>Peek the latest looks in action</p>
    <div class="columns">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/gallery-3.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/gallery-4.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/gallery-1.avif" alt="Gallery"></picture></div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/gallery-2.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/adventure-spots.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/gallery-6.avif" alt="Gallery"></picture></div>
      </div>
    </div>
  </div>
  <hr>
  <div class="section-metadata">
    <div><div>style</div><div>accent</div></div>
  </div>
  <div>
    <h2>Fresh looks, bold vibes, endless inspo</h2>
    <p>Stay inspired with the latest trends and stories.</p>
    <p><strong><a href="#">Subscribe</a></strong></p>
  </div>
</main>
</body>
FIEOF
upload_file "$TMP_DIR/fashion-insights.html" "/fashion-insights.html" "text/html"

# --- fashion-trends-of-the-season.html ---
cat > "$TMP_DIR/fashion-trends-of-the-season.html" << 'FTSEOF'
<body>
<header>
  <div>
    <div>
      <div>
        <p><picture><img src="https://wknd-trendsetters.site/images/mobile-game-character.avif" alt="Hero"></picture></p>
        <p><picture><img src="https://wknd-trendsetters.site/images/hero-family-vacation.avif" alt="Hero"></picture></p>
      </div>
      <div>
        <h1>Fresh fits, bold moves — Trends for every vibe.</h1>
        <p>From tennis whites to neon nights, we're serving up the coolest outfits and the real stories behind them. Get inspired, get noticed, and make every day a runway.</p>
        <p><strong><a href="#trends">See trends</a></strong></p>
        <p><em><a href="/fashion-insights">Explore the blog</a></em></p>
      </div>
    </div>
  </div>
</header>
<main>
  <div>
    <div class="columns">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/season-trend-1.avif" alt="Trend alert"></picture></div>
        <div>
          <h2>Trend alert</h2>
          <h3>Trendy looks, real moments</h3>
          <p>Dive into the latest street style, sporty looks, and party-ready outfits. Discover how young trendsetters are rocking new brands while living their best lives—on the court, at the beach, or out all night.</p>
          <p><a href="/fashion-trends-young-adults">Explore young adult trends</a></p>
        </div>
      </div>
    </div>
  </div>
  <hr>
  <div>
    <h2>Trends that turn heads</h2>
    <div class="cards no-images">
      <div>
        <div>
          <h3>Street style</h3>
          <p>Bold sneakers, vintage tees, oversized hoodies—street style is all about mixing textures and making a statement with every step.</p>
        </div>
      </div>
      <div>
        <div>
          <h3>Sporty vibes</h3>
          <p>Track pants, crop tops, fresh kicks—sporty vibes bring energy and comfort together for looks that move with you.</p>
        </div>
      </div>
      <div>
        <div>
          <h3>Night out</h3>
          <p>Neon accents, metallics, statement pieces—night out fashion is about turning heads and owning the moment.</p>
        </div>
      </div>
    </div>
  </div>
  <hr>
  <div>
    <h2>Style in every snapshot</h2>
    <p>Peek the latest looks in action</p>
    <div class="columns">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/gallery-3.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/gallery-4.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/gallery-1.avif" alt="Gallery"></picture></div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/gallery-2.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/adventure-spots.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/gallery-6.avif" alt="Gallery"></picture></div>
      </div>
    </div>
  </div>
  <hr>
  <div class="section-metadata">
    <div><div>style</div><div>accent</div></div>
  </div>
  <div>
    <h2>Fresh looks, bold vibes, endless inspo</h2>
    <p>Stay inspired with the latest trends and stories.</p>
    <p><strong><a href="#">Join now</a></strong></p>
  </div>
</main>
</body>
FTSEOF
upload_file "$TMP_DIR/fashion-trends-of-the-season.html" "/fashion-trends-of-the-season.html" "text/html"

# --- fashion-trends-young-adults-casual-sport.html ---
cat > "$TMP_DIR/fashion-trends-young-adults-casual-sport.html" << 'FTCSEOF'
<body>
<header>
  <div>
    <div>
      <div>
        <p><picture><img src="https://wknd-trendsetters.site/images/mobile-game-character.avif" alt="Hero"></picture></p>
        <p><picture><img src="https://wknd-trendsetters.site/images/customer-headshot.avif" alt="Hero"></picture></p>
      </div>
      <div>
        <h1>Fresh fits, bold moves, all you</h1>
        <p>From tennis courts to neon nights, we're serving up the latest trends and stories from the coolest scenes.</p>
        <p><strong><a href="#trends">See trends</a></strong></p>
      </div>
    </div>
  </div>
</header>
<main>
  <div>
    <h2>Trend alert</h2>
    <p>Fresh fits, bold moves</p>
    <div class="cards">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/hero-hiphop-dance.avif" alt="Tennis looks"></picture></div>
        <div>
          <p>Casual</p>
          <h3><a href="/fashion-trends-young-adults">Tennis looks that serve</a></h3>
          <p>Ace your day with sporty style that works on and off the court.</p>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/hero-music-concert.avif" alt="Beach style"></picture></div>
        <div>
          <p>Beach</p>
          <h3><a href="/fashion-trends-young-adults">Sunkissed & effortless</a></h3>
          <p>Taylor chills seaside with breezy looks that never miss.</p>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/celebrities-events.avif" alt="Nightlife"></picture></div>
        <div>
          <p>Nightlife</p>
          <h3><a href="/fashion-trends-young-adults">Party after dark</a></h3>
          <p>Morgan lights up the night with bold fits and neon vibes.</p>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/networking-event.avif" alt="Street style"></picture></div>
        <div>
          <p>Street</p>
          <h3><a href="/fashion-trends-young-adults">City strolls, cool fits</a></h3>
          <p>Jordan mixes oversized hoodies with fresh kicks for the ultimate street look.</p>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/trending-outfits.avif" alt="Sport style"></picture></div>
        <div>
          <p>Sport</p>
          <h3><a href="/fashion-trends-young-adults">Move in style</a></h3>
          <p>Casey's athleisure edit blends comfort with head-turning style.</p>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/successful-events.avif" alt="Festival style"></picture></div>
        <div>
          <p>Festival</p>
          <h3><a href="/fashion-trends-young-adults">Vibes for days</a></h3>
          <p>Skylar's festival picks bring color, fun, and serious style energy.</p>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/shopping-bag.avif" alt="Chill style"></picture></div>
        <div>
          <p>Chill</p>
          <h3><a href="/fashion-trends-young-adults">Laid-back, always cool</a></h3>
          <p>Riley keeps it comfy with cozy fits that still look put together.</p>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/people-coffee.avif" alt="Retro style"></picture></div>
        <div>
          <p>Retro</p>
          <h3><a href="/fashion-trends-young-adults">Throwback energy</a></h3>
          <p>Avery brings back '90s flair with bold prints and vintage layers.</p>
        </div>
      </div>
    </div>
  </div>
  <hr>
  <div class="section-metadata">
    <div><div>style</div><div>secondary</div></div>
  </div>
  <div>
    <div class="columns">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/bustling-pub.avif" alt="Fresh fits"></picture></div>
        <div>
          <h2>Fresh fits, bold moves</h2>
          <p>Dive into the latest street style, sporty looks, and party-ready outfits.</p>
          <p><strong><a href="/fashion-insights">Explore the blog</a></strong></p>
        </div>
      </div>
    </div>
  </div>
  <hr>
  <div class="section-metadata">
    <div><div>style</div><div>accent</div></div>
  </div>
  <div>
    <h2>Fresh fits, bold moves, all day</h2>
    <p>Join our community of trendsetters.</p>
    <p><strong><a href="#">Subscribe</a></strong></p>
  </div>
</main>
</body>
FTCSEOF
upload_file "$TMP_DIR/fashion-trends-young-adults-casual-sport.html" "/fashion-trends-young-adults-casual-sport.html" "text/html"

# --- fashion-trends-young-adults.html ---
cat > "$TMP_DIR/fashion-trends-young-adults.html" << 'FTAEOF'
<body>
<header>
  <div>
    <div>
      <div>
        <p><picture><img src="https://wknd-trendsetters.site/images/cycling-event.avif" alt="Hero"></picture></p>
        <p><picture><img src="https://wknd-trendsetters.site/images/hero-music-concert.avif" alt="Hero"></picture></p>
        <p><picture><img src="https://wknd-trendsetters.site/images/party-vacation.avif" alt="Hero"></picture></p>
      </div>
      <div>
        <h1>Fresh fits, bold moves. Style that never sleeps</h1>
        <p>Dive into the latest streetwear, sport-inspired looks, and party-ready outfits. See how real people rock new brands while living their best lives—on the court, at the beach, or out all night.</p>
        <p><strong><a href="#trends">See trends</a></strong></p>
        <p><em><a href="/fashion-insights">Explore the blog</a></em></p>
      </div>
    </div>
  </div>
</header>
<main>
  <div>
    <div class="columns">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/casual-trend.avif" alt="Tennis looks"></picture></div>
        <div>
          <h2>Tennis looks, game strong</h2>
          <p>Crisp polos, bold sneakers, and clean lines—tennis fashion is serving up style that works on the court and on the streets.</p>
        </div>
      </div>
    </div>
  </div>
  <hr>
  <div>
    <div class="columns">
      <div>
        <div>
          <h2>Beach vibes, sun-kissed style</h2>
          <p>Breezy linen, bucket hats, and sandals—beach fashion is all about effortless cool that takes you from sand to sidewalk.</p>
        </div>
        <div><picture><img src="https://wknd-trendsetters.site/images/beach-destination.avif" alt="Beach vibes"></picture></div>
      </div>
    </div>
  </div>
  <hr>
  <div>
    <div class="columns">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/party-accessories.avif" alt="Party nights"></picture></div>
        <div>
          <h2>Party nights, trend on</h2>
          <p>Neon accents, metallics, and statement jackets—night out fashion is about owning the spotlight and having the time of your life.</p>
        </div>
      </div>
    </div>
  </div>
  <hr>
  <div>
    <h2>Young style, real stories</h2>
    <p>Dive into the latest looks, street style inspo, and stories from the coolest scenes.</p>
  </div>
  <hr>
  <div>
    <h2>Trends for every vibe</h2>
    <div class="cards">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/casual-trend.avif" alt="Tennis"></picture></div>
        <div>
          <p>Casual · May 12</p>
          <h3><a href="/blog/latest-trends-young-casual-fashion">Tennis looks that serve</a></h3>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/beach-destination.avif" alt="Sporty"></picture></div>
        <div>
          <p>Sporty · May 10</p>
          <h3><a href="/blog/fashion-trends-young-culture">Streetwear on the move</a></h3>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/networking-event.avif" alt="Beach"></picture></div>
        <div>
          <p>Beach · May 8</p>
          <h3><a href="/blog/fashion-trends-young-style">Sunkissed & styled</a></h3>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/party-accessories.avif" alt="Party"></picture></div>
        <div>
          <p>Party · May 5</p>
          <h3><a href="/blog/fashion-blog-post">Night out, bold fits</a></h3>
        </div>
      </div>
    </div>
  </div>
  <hr>
  <div>
    <h2>Style in every snapshot</h2>
    <p>Trendy looks, real moments</p>
    <div class="columns">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/game-characters.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/gallery-2.avif" alt="Gallery"></picture></div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/concert-crowd.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/hero-hiphop-dance.avif" alt="Gallery"></picture></div>
      </div>
    </div>
  </div>
  <hr>
  <div class="section-metadata">
    <div><div>style</div><div>accent</div></div>
  </div>
  <div>
    <h2>Fresh fits, bold moves</h2>
    <p>Join our community of trendsetters.</p>
    <p><strong><a href="#">Subscribe</a></strong></p>
  </div>
</main>
</body>
FTAEOF
upload_file "$TMP_DIR/fashion-trends-young-adults.html" "/fashion-trends-young-adults.html" "text/html"

# --- case-studies.html ---
cat > "$TMP_DIR/case-studies.html" << 'CSEOF'
<body>
<header>
  <div>
    <div>
      <div><picture><img src="https://wknd-trendsetters.site/images/adventure-spots.avif" alt="Case studies hero"></picture></div>
      <div>
        <h1>Fresh looks, bold stories, real life</h1>
        <p>Dive into our latest style adventures—see how young trendsetters own every moment, from courtside to the dance floor.</p>
        <p><strong><a href="#cases">See case</a></strong></p>
      </div>
    </div>
  </div>
</header>
<main>
  <div>
    <h2>Fresh looks, bold moves, real stories</h2>
    <p>Taylor Brooks · June 12, 2024 · 4 min read</p>
  </div>
  <hr>
  <div>
    <h2>Style in every snapshot</h2>
    <p>Peek the latest looks in action</p>
    <div class="columns">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/hero-hiphop-dance.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/beach-destination.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/concert-crowd.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/campus-life.avif" alt="Gallery"></picture></div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/gaming-tournaments.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/mobile-game-character.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/fashion-inspiration.avif" alt="Gallery"></picture></div>
        <div><picture><img src="https://wknd-trendsetters.site/images/campus-tour.avif" alt="Gallery"></picture></div>
      </div>
    </div>
  </div>
  <hr>
  <div>
    <div class="tabs">
      <div>
        <div>Alex Rivera</div>
        <div>
          <div class="columns">
            <div>
              <div><picture><img src="https://wknd-trendsetters.site/images/hero-hiphop-dance.avif" alt="Alex Rivera"></picture></div>
              <div>
                <p>"Wearing new brands makes every day feel like a runway. I love mixing sporty vibes with bold colors—perfect for tennis or a night out!"</p>
                <p><picture><img src="https://wknd-trendsetters.site/images/avatar-alex.avif" alt="Alex Rivera" width="60" height="60"></picture></p>
                <p><strong>Alex Rivera</strong></p>
                <p>Streetwear Enthusiast</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div>
        <div>Taylor Kim</div>
        <div>
          <div class="columns">
            <div>
              <div><picture><img src="https://wknd-trendsetters.site/images/tab-campus.avif" alt="Taylor Kim"></picture></div>
              <div>
                <p>"Fresh looks, comfy fits—my go-to for beach days and city strolls. These brands keep my style on point and effortless."</p>
                <p><picture><img src="https://wknd-trendsetters.site/images/avatar-taylor.avif" alt="Taylor Kim" width="60" height="60"></picture></p>
                <p><strong>Taylor Kim</strong></p>
                <p>Casual Style Blogger</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div>
        <div>Jordan Ellis</div>
        <div>
          <div class="columns">
            <div>
              <div><picture><img src="https://wknd-trendsetters.site/images/tab-staff.avif" alt="Jordan Ellis"></picture></div>
              <div>
                <p>"Nothing beats the confidence boost from a killer outfit. I'm always ready for spontaneous adventures in these cool threads."</p>
                <p><picture><img src="https://wknd-trendsetters.site/images/avatar-jordan.avif" alt="Jordan Ellis" width="60" height="60"></picture></p>
                <p><strong>Jordan Ellis</strong></p>
                <p>Trend Spotter</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div>
        <div>Morgan Blake</div>
        <div>
          <div class="columns">
            <div>
              <div><picture><img src="https://wknd-trendsetters.site/images/mobile-game-character.avif" alt="Morgan Blake"></picture></div>
              <div>
                <p>"From rooftop parties to late-night hangs, these styles turn heads. Fashion should be fun, and this is pure fun!"</p>
                <p><picture><img src="https://wknd-trendsetters.site/images/avatar-morgan.avif" alt="Morgan Blake" width="60" height="60"></picture></p>
                <p><strong>Morgan Blake</strong></p>
                <p>Party Scene Curator</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  <hr>
  <div>
    <div class="columns">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/networking-event.avif" alt="CTA"></picture></div>
        <div>
          <h2>Fresh looks, bold stories, real life</h2>
          <p>Dive into our latest case study: see how young trendsetters rock new brands from courtside to the dance floor. Discover the style, the vibe, and the impact—one story at a time.</p>
          <p><strong><a href="#">See more</a></strong></p>
        </div>
      </div>
    </div>
  </div>
</main>
</body>
CSEOF
upload_file "$TMP_DIR/case-studies.html" "/case-studies.html" "text/html"

# --- faq.html ---
cat > "$TMP_DIR/faq.html" << 'FAQEOF'
<body>
<header>
  <div>
    <div>
      <div><picture><img src="https://wknd-trendsetters.site/images/faq-hero.avif" alt="FAQ hero"></picture></div>
      <div>
        <h1>Got questions? We've got answers.</h1>
        <p>Fashion FAQs, answered fast</p>
        <p>Curious about trends, tips, or our vibe? Find all the style scoop and community know-how right here.</p>
      </div>
    </div>
  </div>
</header>
<main>
  <div>
    <div class="accordion">
      <div>
        <div>
          <h2>Frequently Asked Questions</h2>
        </div>
      </div>
      <div>
        <div>How do I spot the latest trends?</div>
        <div><p>We keep it fresh! Check our weekly trend roundups and street style snaps for what's hot right now.</p></div>
      </div>
      <div>
        <div>Can I share my own outfit pics?</div>
        <div><p>Absolutely! Tag us on socials or use our upload form to get featured in our next style story.</p></div>
      </div>
      <div>
        <div>Where do you find your style inspo?</div>
        <div><p>From city streets to beach parties, we're always on the lookout for bold looks and cool creators.</p></div>
      </div>
      <div>
        <div>How can I join your community?</div>
        <div><p>Sign up for our newsletter or jump into the comments—everyone's welcome to join the fun!</p></div>
      </div>
    </div>
  </div>
  <hr>
  <div>
    <h2>Contact Us</h2>
    <p>Email: hello@fashionblog.com</p>
    <p>Phone: +1 (555) 123-9876</p>
    <p>Address: 101 Trend Ave, San Francisco, CA</p>
  </div>
  <hr>
  <div class="section-metadata">
    <div><div>style</div><div>accent</div></div>
  </div>
  <div>
    <h2>Fresh fits, bold moves, all day</h2>
    <p>Join our community of trendsetters.</p>
    <p><strong><a href="#">Join now</a></strong></p>
  </div>
</main>
</body>
FAQEOF
upload_file "$TMP_DIR/faq.html" "/faq.html" "text/html"

# --- blog.html (blog index) ---
cat > "$TMP_DIR/blog-index.html" << 'BLOGEOF'
<body>
<header>
  <div>
    <div>
      <div><picture><img src="https://wknd-trendsetters.site/images/fashion-insights-hero.avif" alt="Blog hero"></picture></div>
      <div>
        <h1>WKND Trendsetters Blog</h1>
        <p>From tennis courts to neon nights, discover the latest trends, style inspo, and stories from the coolest scenes. Dive into a world where fashion meets fun—your next look starts here.</p>
        <p><strong><a href="#articles">Read now</a></strong></p>
        <p><em><a href="/fashion-trends-of-the-season">See trends</a></em></p>
      </div>
    </div>
  </div>
</header>
<main>
  <div>
    <div class="columns">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/ace-polo-court-style.avif" alt="Featured article"></picture></div>
        <div>
          <p>Featured · February 23, 2026</p>
          <h2>Court cool, street ready — the Ace Pro polo</h2>
          <p>Alex Rivera and Taylor Kim break down the polo that serves on the court and turns heads on the sidewalk.</p>
          <p><a href="/blog/ace-pro-court-polo">Read the full article</a></p>
        </div>
      </div>
    </div>
  </div>
  <hr>
  <div>
    <h2>Latest Articles</h2>
    <div class="cards">
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/flip-flop-beach-style.avif" alt="Flip flop style"></picture></div>
        <div>
          <p>Beach Vibes · Feb 22, 2026</p>
          <h3><a href="/blog/flip-flop-summer-style">Slide into summer — flip flops that serve</a></h3>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/hero-hiphop-dance.avif" alt="Tennis style"></picture></div>
        <div>
          <p>Casual Cool · June 12, 2024</p>
          <h3><a href="/blog/latest-trends-young-casual-fashion">Tennis style, redefined</a></h3>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/fundraising-event.avif" alt="Beach vibes"></picture></div>
        <div>
          <p>Beach Vibes · June 10, 2024</p>
          <h3><a href="/blog/fashion-trends-young-culture">Sunkissed and effortless</a></h3>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/hero-family-vacation.avif" alt="Party fits"></picture></div>
        <div>
          <p>Night Out · June 8, 2024</p>
          <h3><a href="/blog/fashion-trends-young-style">Party fits that pop</a></h3>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/mobile-game-character.avif" alt="Sport mode"></picture></div>
        <div>
          <p>Sport Mode · June 5, 2024</p>
          <h3><a href="/blog/fashion-blog-post">Game on, style up</a></h3>
        </div>
      </div>
      <div>
        <div><picture><img src="https://wknd-trendsetters.site/images/street-style.avif" alt="Street style"></picture></div>
        <div>
          <p>Street Style · June 2, 2024</p>
          <h3><a href="/blog/street-style-trends">Street style, your way</a></h3>
        </div>
      </div>
    </div>
  </div>
  <hr>
  <div class="section-metadata">
    <div><div>style</div><div>accent</div></div>
  </div>
  <div>
    <h2>Fresh looks, bold vibes, endless inspo</h2>
    <p>Stay inspired with the latest trends and stories.</p>
    <p><strong><a href="#">Subscribe</a></strong></p>
  </div>
</main>
</body>
BLOGEOF
upload_file "$TMP_DIR/blog-index.html" "/blog.html" "text/html"

# --- blog posts ---
# blog/latest-trends-young-casual-fashion.html
cat > "$TMP_DIR/blog-casual.html" << 'B1EOF'
<body>
<header>
  <div>
    <div>
      <div><picture><img src="https://wknd-trendsetters.site/images/hero-hiphop-dance.avif" alt="Tennis style hero"></picture></div>
      <div>
        <h1>Tennis style, redefined</h1>
      </div>
    </div>
  </div>
</header>
<main>
  <div>
    <p>Taylor Brooks · June 12, 2024 · 4 min read · Casual Cool</p>
    <h2>Serve Up Style on and off the Court</h2>
    <p>Tennis isn't just a sport—it's a whole cultural moment. This season, court-to-street fashion is bigger than ever, mixing classic whites with bold colors, oversized silhouettes, and retro-inspired accessories. Whether you're hitting the courts or just hitting the town, these looks serve every time.</p>
    <h2>The New Tennis Aesthetic</h2>
    <p>Gone are the days when tennis wear meant plain white polos and pleated skirts. Today's tennis aesthetic borrows from streetwear, athleisure, and even high fashion. Think oversized polo shirts in unexpected colors, pairing pleated skirts with chunky sneakers, and topping it all off with vintage-inspired sweatbands.</p>
    <h3>Key Pieces to Watch</h3>
    <ul>
      <li>Vintage polo shirts in pastels and bold stripes</li>
      <li>Pleated mini skirts paired with high-top sneakers</li>
      <li>Oversized visors and sweatbands as accessories</li>
      <li>Retro track jackets with modern relaxed fits</li>
      <li>White sneakers with bold colored accents</li>
    </ul>
    <h2>How Trendsetters Wear It</h2>
    <p>"Wearing new brands makes every day feel like a runway. I love mixing sporty vibes with bold colors—perfect for tennis or a night out!" — Alex Rivera, Streetwear Enthusiast</p>
    <h2>Make It Your Own</h2>
    <p>The best part about the tennis trend? It's totally personal. Layer a track jacket over a dress, pair a polo with baggy jeans, or go full vintage with a matching set. The key is confidence—own your look and make it yours.</p>
    <blockquote><p>"Style is about expressing who you are. Tennis fashion gives you that preppy base, but you can take it anywhere." — Jordan Ellis, Trend Spotter</p></blockquote>
  </div>
</main>
</body>
B1EOF
upload_file "$TMP_DIR/blog-casual.html" "/blog/latest-trends-young-casual-fashion.html" "text/html"

# blog/fashion-trends-young-culture.html
cat > "$TMP_DIR/blog-culture.html" << 'B2EOF'
<body>
<header>
  <div>
    <div>
      <div><picture><img src="https://wknd-trendsetters.site/images/fundraising-event.avif" alt="Beach vibes hero"></picture></div>
      <div>
        <h1>Sunkissed and effortless</h1>
      </div>
    </div>
  </div>
</header>
<main>
  <div>
    <p>Taylor Brooks · June 10, 2024 · 5 min read · Beach Vibes</p>
    <h2>Beach Days, Best Days</h2>
    <p>Summer is here, and so is the ultimate beach fashion. This season, it's all about effortless style—think breezy fabrics, sun-washed colors, and accessories that take you from sand to street without missing a beat. The beach isn't just a destination; it's a state of mind.</p>
    <h2>The Sunkissed Edit</h2>
    <p>"Fresh looks, comfy fits—my go-to for beach days and city strolls. These brands keep my style on point and effortless." — Taylor Kim, Casual Style Blogger</p>
    <h3>Must-Have Beach Pieces</h3>
    <ul>
      <li>Linen button-downs in earth tones and pastels</li>
      <li>Wide-leg trousers that catch the breeze</li>
      <li>Bucket hats in canvas and crochet</li>
      <li>Woven tote bags for essentials</li>
      <li>Chunky sandals for sand and sidewalks</li>
    </ul>
    <h2>From Shore to Street</h2>
    <p>The magic of beach fashion is its versatility. A linen shirt thrown over swim trunks works for a seaside lunch, then swap the sandals for sneakers and you're ready for an evening out. It's all about layering and keeping things relaxed.</p>
    <h2>Color Stories</h2>
    <p>This season's beach palette leans into sandy beiges, ocean blues, coral pinks, and sage greens. Mix and match these shades for a look that's as calm as the tide—or go bold with a pop of neon for sunset vibes.</p>
    <blockquote><p>"Beach fashion should feel like a vacation—even when you're just running errands." — Morgan Ellis, Waveform</p></blockquote>
  </div>
</main>
</body>
B2EOF
upload_file "$TMP_DIR/blog-culture.html" "/blog/fashion-trends-young-culture.html" "text/html"

# blog/fashion-trends-young-style.html
cat > "$TMP_DIR/blog-style.html" << 'B3EOF'
<body>
<header>
  <div>
    <div>
      <div><picture><img src="https://wknd-trendsetters.site/images/hero-family-vacation.avif" alt="Party fits hero"></picture></div>
      <div>
        <h1>Party fits that pop</h1>
      </div>
    </div>
  </div>
</header>
<main>
  <div>
    <p>Taylor Brooks · June 8, 2024 · 4 min read · Night Out</p>
    <h2>Glow Up After Dark</h2>
    <p>When the sun goes down, the fashion turns up. Nightlife fashion is all about making a statement—bold textures, unexpected combos, and pieces that catch every light in the room. Whether you're hitting a rooftop party or a late-night hang, these looks will make sure you're the one people remember.</p>
    <h2>Morgan's Night Out Edit</h2>
    <p>"From rooftop parties to late-night hangs, these styles turn heads. Fashion should be fun, and this is pure fun!" — Morgan Blake, Party Scene Curator</p>
    <h3>The Party Essentials</h3>
    <ul>
      <li>Metallic tops that catch every light</li>
      <li>Statement jackets with bold prints or sequins</li>
      <li>Platform shoes for height and drama</li>
      <li>Layered jewelry—the more the better</li>
      <li>Mini bags in unexpected colors</li>
    </ul>
    <h2>The Neon Revival</h2>
    <p>Neon isn't just a color—it's an attitude. This season, neon accents are popping up everywhere, from neon piping on jackets to glow-in-the-dark accessories. The trick? Use neon as an accent, not a full look. A neon belt or a pair of neon earrings can elevate any outfit.</p>
    <h2>Confidence is the Best Accessory</h2>
    <p>At the end of the night, the best outfit is the one that makes you feel unstoppable. Don't be afraid to experiment—mix patterns, try new textures, and most importantly, wear what makes you happy.</p>
    <h2>After-Dark Trends to Try</h2>
    <p>This season's nightlife looks are all about texture mixing. Think velvet paired with metallic, or sequins with denim. The contrast creates visual interest and shows you know how to play with fashion.</p>
    <blockquote><p>"Your party outfit should be as memorable as the night itself." — Jordan Blake, Night Owl</p></blockquote>
  </div>
</main>
</body>
B3EOF
upload_file "$TMP_DIR/blog-style.html" "/blog/fashion-trends-young-style.html" "text/html"

# blog/fashion-blog-post.html
cat > "$TMP_DIR/blog-post.html" << 'B4EOF'
<body>
<header>
  <div>
    <div>
      <div><picture><img src="https://wknd-trendsetters.site/images/mobile-game-character.avif" alt="Sport mode hero"></picture></div>
      <div>
        <h1>Game on, style up</h1>
      </div>
    </div>
  </div>
</header>
<main>
  <div>
    <p>Taylor Brooks · June 5, 2024 · 4 min read</p>
    <h2>Athleisure Isn't Going Anywhere</h2>
    <p>Once dismissed as lazy dressing, athleisure has evolved into one of the most important fashion categories of our time. It's no longer just about throwing on gym clothes—it's about curating sport-inspired looks that are elevated, intentional, and undeniably stylish.</p>
    <h2>The Sport Mode Mindset</h2>
    <p>"Sporty, casual, or glam—there's always a look for my mood." — Casey Drew</p>
    <h3>The Updated Athleisure Kit</h3>
    <ul>
      <li>Track pants with bold side stripes or color blocking</li>
      <li>Cropped hoodies in oversized fits</li>
      <li>Retro trainers with chunky soles and vintage colorways</li>
      <li>Sports bras as layered tops under sheer or open shirts</li>
      <li>Windbreakers in graphic prints</li>
    </ul>
    <h2>Beyond the Gym</h2>
    <p>The key to nailing athleisure is balance. Pair track pants with a structured jacket, or style a sports bra under a blazer. It's about mixing the relaxed energy of sportswear with pieces that add polish. Pay attention to proportions, color coordination, and how you accessorize.</p>
    <h2>The Brand Factor</h2>
    <p>Today's athleisure isn't just about big logos—it's about mixing heritage sportswear with independent labels. Layer a vintage track jacket over a local brand's tee, or pair mainstream sneakers with handmade jewelry. The mix is what makes it modern.</p>
    <h2>Active Style, Real Life</h2>
    <p>At its core, sport-inspired fashion is about comfort and confidence. Whether you're biking to class, grabbing coffee, or meeting friends, these are the looks that move with you—literally and figuratively.</p>
    <blockquote><p>"Fashion should move with you, not against you. That's why sport-inspired style will always win." — Riley Quinn, Sunset Crew</p></blockquote>
  </div>
</main>
</body>
B4EOF
upload_file "$TMP_DIR/blog-post.html" "/blog/fashion-blog-post.html" "text/html"

echo ""
echo "=== Import complete ==="
echo "Uploaded: 44 images, 12 content pages"
