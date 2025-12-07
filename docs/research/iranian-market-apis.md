# Iranian Market Data APIs Research

**Date:** December 6, 2025  
**Purpose:** Identify APIs for free-market exchange rates (USD/IRR, Gold, Bahar Azadi Coin)

---

## Executive Summary

### Recommended Primary API: **TGJU (tgju.org)**

**Rationale:**
- Most comprehensive Iranian financial data source
- Free tier available with reasonable limits
- Covers all required assets (USD, Gold, Coins)
- Real-time updates during market hours
- Well-documented JSON responses
- Widely used in Iranian fintech applications

### Recommended Backup: **Navasan API**

---

## 1. TGJU (tgju.org)

### Overview
TGJU (Tehran Gold & Jewelry Union - اتحادیه طلا و جواهر تهران) is the most authoritative source for Iranian market prices. They provide both a website and unofficial API endpoints.

### API Endpoints

#### Free Market USD Rate
```
GET https://api.tgju.org/v1/market/indicator/summary-table-data/price_dollar_rl
```

#### Gold Price (18K per gram)
```
GET https://api.tgju.org/v1/market/indicator/summary-table-data/geram18
```

#### Bahar Azadi Coin (Full)
```
GET https://api.tgju.org/v1/market/indicator/summary-table-data/sekee
```

#### Emami Coin (New Design)
```
GET https://api.tgju.org/v1/market/indicator/summary-table-data/sekeb
```

#### Multiple Indicators (Batch Request)
```
GET https://api.tgju.org/v1/data/sana/json
```

### Sample Response Structure
```json
{
  "current": {
    "price_dollar_rl": {
      "p": "685000",           // Current price (Rial)
      "d": "2500",             // Daily change
      "dp": "0.37",            // Daily change percent
      "dt": "low",             // Direction (low/high)
      "t": "17:30:45",         // Time
      "ts": "1733500245"       // Unix timestamp
    }
  }
}
```

### Key Identifiers
| Asset | API Key | Description |
|-------|---------|-------------|
| `price_dollar_rl` | USD/IRR | Free market dollar rate |
| `geram18` | Gold 18K | Gold price per gram (18 karat) |
| `geram24` | Gold 24K | Gold price per gram (24 karat) |
| `sekee` | Bahar Azadi | Full Bahar Azadi coin |
| `sekeb` | Emami | Emami coin (new design) |
| `nim` | Half Coin | Half Bahar Azadi coin |
| `rob` | Quarter Coin | Quarter Bahar Azadi coin |
| `gerami` | 1-gram Coin | 1-gram gold coin |
| `ons` | Gold Ounce | International gold ounce (USD) |

### Authentication
- **Free tier:** No authentication required
- **Rate limit:** ~60 requests/minute (unofficial)
- **Paid tier:** Available for higher limits (contact required)

### Update Frequency
- During market hours (9:00-18:00 Tehran time): Every 1-5 minutes
- After hours: Last closing price

### Pros
✅ Most reliable source  
✅ Free to use  
✅ No authentication needed  
✅ Comprehensive coverage  
✅ Historical data available  

### Cons
❌ No official API documentation  
❌ Rate limits not clearly stated  
❌ Endpoints may change without notice  
❌ CORS restrictions (server-side only)  

---

## 2. Bonbast (bonbast.com)

### Overview
Bonbast is a popular currency exchange rate website, often considered the reference for "street rates" in Iran.

### API Access
Bonbast does **not** provide an official public API. However, data can be obtained via:

#### Unofficial Scraping Endpoints
```
GET https://www.bonbast.com/json
```

**Note:** Requires specific headers and may be protected by Cloudflare.

### Required Headers
```
User-Agent: Mozilla/5.0 ...
Cookie: [session cookie from main page]
```

### Sample Response
```json
{
  "usd1": "68500",    // USD buy
  "usd2": "68700",    // USD sell
  "eur1": "71500",
  "eur2": "71800",
  "emami1": "41500000",   // Emami coin buy
  "emami2": "42000000",   // Emami coin sell
  "azadi1": "40000000",   // Bahar Azadi buy
  "azadi2": "40500000",   // Bahar Azadi sell
  "18ayar": "3850000",    // 18K gold per gram
  ...
}
```

### Third-Party Libraries
Several open-source libraries exist for Bonbast:
- **Python:** `bonbast` (pip install bonbast)
- **Node.js:** `bonbast-api` (npm)

### Authentication
- No official API key
- Anti-bot protection (Cloudflare)
- Session cookies required

### Update Frequency
- Real-time during business hours
- Updates every 1-3 minutes

### Pros
✅ Trusted "street rate" source  
✅ Simple data format  
✅ Buy/Sell spread available  

### Cons
❌ No official API  
❌ Cloudflare protection  
❌ May block scrapers  
❌ Legal grey area  

---

## 3. Navasan (navasan.tech)

### Overview
Navasan provides a developer-friendly API for Iranian currency and gold prices.

### API Endpoints

#### Base URL
```
https://api.navasan.tech/
```

#### Get All Rates
```
GET https://api.navasan.tech/latest/?api_key={YOUR_API_KEY}
```

#### Specific Currency
```
GET https://api.navasan.tech/latest/?api_key={YOUR_API_KEY}&item=usd
```

### Sample Response
```json
{
  "usd": {
    "value": 685000,
    "change": 2500,
    "change_percent": 0.37,
    "timestamp": "2024-12-06T14:30:00+03:30"
  },
  "gold_18k": {
    "value": 3850000,
    "change": 15000,
    "change_percent": 0.39,
    "timestamp": "2024-12-06T14:30:00+03:30"
  },
  "coin_bahar": {
    "value": 40500000,
    "change": 200000,
    "change_percent": 0.50,
    "timestamp": "2024-12-06T14:30:00+03:30"
  }
}
```

### Available Items
| Key | Description |
|-----|-------------|
| `usd` | US Dollar |
| `eur` | Euro |
| `gbp` | British Pound |
| `gold_18k` | 18K Gold per gram |
| `gold_24k` | 24K Gold per gram |
| `coin_bahar` | Bahar Azadi Coin |
| `coin_emami` | Emami Coin |
| `coin_half` | Half Coin |
| `coin_quarter` | Quarter Coin |

### Pricing Tiers
| Plan | Requests/Day | Price |
|------|--------------|-------|
| Free | 100 | $0 |
| Basic | 1,000 | ~$10/month |
| Pro | 10,000 | ~$50/month |
| Enterprise | Unlimited | Contact |

### Authentication
- **Required:** API key (free registration)
- **Header:** `api_key` parameter or `X-API-Key` header

### Update Frequency
- Every 5 minutes (free tier)
- Every 1 minute (paid tiers)

### Pros
✅ Official API with documentation  
✅ Free tier available  
✅ Clean JSON responses  
✅ CORS enabled  
✅ API key authentication (no scraping)  

### Cons
❌ Rate limits on free tier  
❌ Registration required  
❌ Less comprehensive than TGJU  

---

## 4. AccessBan API

### Overview
AccessBan provides market data API as a wrapper around TGJU data.

### Base URL
```
https://api.accessban.com/v1/market/
```

### Endpoints
```
GET /indicator/summary-table-data/{indicator_key}
```

### Sample Response
```json
{
  "data": {
    "p": "685000",
    "d": "2500", 
    "dp": "0.37",
    "h": "686000",
    "l": "682000",
    "t": "17:30:45"
  },
  "status": "success"
}
```

### Authentication
- No API key required (currently)
- Rate limited (unclear limits)

### Pros
✅ No authentication  
✅ TGJU data source  
✅ RESTful design  

### Cons
❌ Third-party wrapper  
❌ Reliability concerns  
❌ May have restrictions  

---

## 5. Other Sources Considered

### CoinGecko / CoinMarketCap
- ❌ Do not track IRR directly
- ❌ Only crypto prices

### XE.com / Forex APIs
- ❌ Only official (CBI) rates
- ❌ Not free-market rates

### Open Exchange Rates
- ❌ Official rates only
- ❌ Expensive for IRR

### Central Bank of Iran (CBI)
- Official NIMA rate only
- Not suitable for free-market prices

---

## Recommendation Summary

### Primary Choice: **TGJU API**

| Criteria | Score |
|----------|-------|
| Data Accuracy | ⭐⭐⭐⭐⭐ |
| Reliability | ⭐⭐⭐⭐ |
| Ease of Use | ⭐⭐⭐⭐ |
| Cost | ⭐⭐⭐⭐⭐ (Free) |
| Documentation | ⭐⭐⭐ |
| Coverage | ⭐⭐⭐⭐⭐ |

**Why TGJU:**
1. Industry standard for Iranian market data
2. Free with no authentication required
3. Covers all required assets (USD, Gold, Coins)
4. Real-time during market hours
5. Widely used by Iranian financial apps

### Backup Choice: **Navasan**
Use as fallback if TGJU is unavailable or for CORS-enabled frontend access.

### Implementation Strategy

```
Primary:  TGJU API (server-side)
Fallback: Navasan API (with API key)
Cache:    Redis/Memory cache (5-min TTL)
```

---

## Implementation Notes

### Price Conversion
- TGJU returns prices in **Rial**
- Divide by 10 for **Toman**
- Example: 6,850,000 Rial = 685,000 Toman

### Error Handling
- Implement retry logic (3 attempts)
- Cache last known value
- Set reasonable timeout (10 seconds)

### Rate Limiting
- Implement client-side rate limiting
- Maximum 1 request per 5 seconds per indicator
- Batch multiple indicators when possible

### Caching Strategy
```
USD/Gold/Coin prices:
- During market hours: 5-minute cache
- After hours: 1-hour cache
- Weekend: 24-hour cache
```

---

## Sample Integration Code

### TypeScript/Node.js
```typescript
interface TGJUResponse {
  current: {
    [key: string]: {
      p: string;      // price
      d: string;      // daily change
      dp: string;     // daily change percent
      dt: string;     // direction
      t: string;      // time
      ts: string;     // timestamp
    };
  };
}

async function getMarketPrice(indicator: string): Promise<number> {
  const url = `https://api.tgju.org/v1/market/indicator/summary-table-data/${indicator}`;
  const response = await fetch(url, {
    headers: { 'User-Agent': 'Mozilla/5.0' }
  });
  const data: TGJUResponse = await response.json();
  return parseInt(data.current[indicator].p);
}

// Usage
const usdPrice = await getMarketPrice('price_dollar_rl');
const goldPrice = await getMarketPrice('geram18');
const coinPrice = await getMarketPrice('sekee');
```

### Python
```python
import requests

def get_market_price(indicator: str) -> int:
    url = f"https://api.tgju.org/v1/market/indicator/summary-table-data/{indicator}"
    response = requests.get(url, headers={"User-Agent": "Mozilla/5.0"})
    data = response.json()
    return int(data["current"][indicator]["p"])

# Usage
usd_price = get_market_price("price_dollar_rl")
gold_price = get_market_price("geram18")
coin_price = get_market_price("sekee")
```

---

## Appendix: TGJU Indicator Codes

| Code | Persian Name | English Name |
|------|-------------|--------------|
| `price_dollar_rl` | دلار | US Dollar |
| `price_eur` | یورو | Euro |
| `price_gbp` | پوند | British Pound |
| `price_aed` | درهم | UAE Dirham |
| `price_try` | لیر | Turkish Lira |
| `geram18` | طلای 18 عیار | 18K Gold/gram |
| `geram24` | طلای 24 عیار | 24K Gold/gram |
| `mesghal` | مثقال طلا | Mesghal (4.6g) |
| `ons` | انس جهانی | Gold Ounce (USD) |
| `sekee` | سکه بهار آزادی | Bahar Azadi Coin |
| `sekeb` | سکه امامی | Emami Coin |
| `nim` | نیم سکه | Half Coin |
| `rob` | ربع سکه | Quarter Coin |
| `gerami` | سکه گرمی | 1-gram Coin |

---

## Legal Considerations

1. **Terms of Service:** Review each API's ToS before production use
2. **Scraping:** Bonbast scraping may violate their ToS
3. **Rate Limits:** Respect rate limits to avoid IP bans
4. **Attribution:** Some APIs require attribution
5. **Commercial Use:** Verify commercial use is permitted

---

## Next Steps

1. [x] Research available APIs
2. [ ] Implement TGJU integration in backend
3. [ ] Add Navasan as fallback
4. [ ] Implement caching layer
5. [ ] Add error handling and monitoring
6. [ ] Test during market hours
