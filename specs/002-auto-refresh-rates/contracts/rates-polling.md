# API Contract: Auto-Refresh Rates Polling

**Feature**: 002-auto-refresh-rates  
**Date**: December 25, 2025  
**Status**: No Changes Required (using existing endpoint)

## Overview

The auto-refresh feature uses the existing `/api/v1/rates` endpoint. No API modifications are needed. This document clarifies the polling contract and caching behavior.

## Endpoint

**Existing Endpoint**: `GET /api/v1/rates`

**Access**: Public (no authentication required)  
**Polling Frequency**: Every 5 minutes when screen is active  
**Backend Update Frequency**: Every 5 minutes (via background job)

---

## Request

### HTTP Method
```
GET /api/v1/rates
```

### Headers
```
Accept: application/json
Content-Type: application/json
```

**No authentication headers** - rates are public data

### Query Parameters
None

### Request Body
None (GET request)

---

## Response

### Success Response (200 OK)

```json
{
  "status": "success",
  "data": {
    "rates": [
      {
        "rate_type": "usd",
        "value_in_toman": 705000,
        "label": "دلار آمریکا",
        "timestamp": "2025-12-25T11:30:00.000+03:30",
        "stale": false,
        "change_percent": 1.5,
        "change_direction": "up"
      },
      {
        "rate_type": "gold_gram",
        "value_in_toman": 3250000,
        "label": "طلا (گرم)",
        "timestamp": "2025-12-25T11:30:00.000+03:30",
        "stale": false,
        "change_percent": -0.3,
        "change_direction": "down"
      },
      {
        "rate_type": "bahar_azadi",
        "value_in_toman": 48500000,
        "label": "سکه بهار آزادی",
        "timestamp": "2025-12-25T11:30:00.000+03:30",
        "stale": false,
        "change_percent": 0.0,
        "change_direction": "stable"
      }
    ],
    "timestamp": "2025-12-25T11:30:00.000+03:30",
    "rates_stale_minutes": 3,
    "stale": false
  }
}
```

### Response Fields

| Field | Type | Description | Notes |
|-------|------|-------------|-------|
| `rates` | Array | List of current market rates | Always 3 items (USD, Gold, Bahar Azadi) |
| `rates[].rate_type` | String | Rate identifier | "usd", "gold_gram", "bahar_azadi" |
| `rates[].value_in_toman` | Integer | Current value in Toman | Whole number, no decimals |
| `rates[].label` | String | Persian display label | For UI display |
| `rates[].timestamp` | String (ISO 8601) | When rate was last updated | Includes timezone (+03:30 for Tehran) |
| `rates[].stale` | Boolean | Whether rate is >5 minutes old | Used for UI indicator |
| `rates[].change_percent` | Float | Percent change from 1 hour ago | Can be positive, negative, or zero |
| `rates[].change_direction` | String | Direction of change | "up", "down", or "stable" |
| `timestamp` | String (ISO 8601) | Timestamp of response | Same as rates[0].timestamp |
| `rates_stale_minutes` | Integer | Minutes since last update | For UI display |
| `stale` | Boolean | Whether any rate is stale | Global stale indicator |

### Cache Headers

```
Cache-Control: public, max-age=300
ETag: "<md5-hash-of-rates>"
```

**Client Behavior**:
- Client MAY respect `Cache-Control` but auto-refresh overrides (fetches every 5 minutes regardless)
- Client SHOULD NOT use ETag conditional requests (always want fresh data)
- Backend updates rates every 5 minutes, so polling at same interval is optimal

---

## Error Responses

### 500 Internal Server Error

```json
{
  "status": "error",
  "message": "Failed to fetch rates: Connection timeout"
}
```

**Client Handling**:
- Keep existing rates displayed
- Show error notification (optional)
- Retry on next scheduled interval (5 minutes)
- Do NOT retry immediately

### Network Errors (No Response)

**Scenarios**:
- Client offline
- Server unreachable
- Request timeout

**Client Handling**:
- Catch exception in HTTP client
- Keep existing rates displayed
- Show stale indicator if timestamp >5 minutes
- Retry on next scheduled interval
- Do NOT show blocking error UI

---

## Polling Contract

### Auto-Refresh Behavior

**When to Poll**:
- Initial load: Immediately when screen opens
- Periodic: Every 5 minutes while screen is visible
- After resume: Immediately when app returns to foreground
- After manual: NOT polled (manual refresh resets timer)

**When NOT to Poll**:
- App is backgrounded
- Screen is not visible
- Manual refresh in progress
- Previous auto-refresh still in progress

### Timing Diagram

```
T=0:00   Screen opens        → Fetch immediately
T=5:00   Timer fires         → Auto-refresh (fetch)
T=7:30   User manual refresh → Fetch, reset timer
T=12:30  Timer fires         → Auto-refresh (fetch)
T=15:00  App backgrounded    → Timer paused, no fetch
T=20:00  (Timer would fire)  → No fetch (backgrounded)
T=22:00  App resumed         → Fetch immediately, restart timer
T=27:00  Timer fires         → Auto-refresh (fetch)
```

---

## Rate Limiting Considerations

**Backend Rate Limiting**: None currently implemented  
**Client Self-Limiting**: 5-minute interval prevents excessive requests  
**Peak Load**: Max 1 request per user per 5 minutes when active

**Calculation**:
- 10,000 active users
- All screens visible
- Synchronized polling (worst case)
- = 10,000 requests / 5 minutes
- = 33 requests/second (backend can handle easily)

**No rate limiting needed** at current scale.

---

## Testing Contract

### Test Scenarios

1. **Successful polling sequence**:
   - Request at T=0, T=5, T=10 minutes
   - Verify 3 responses received
   - Verify data updates reflected in UI

2. **Network error handling**:
   - Simulate network failure at T=5
   - Verify existing data persists
   - Verify retry at T=10

3. **Background/foreground transition**:
   - Pause at T=3 (before timer)
   - Resume at T=8
   - Verify immediate fetch on resume
   - Verify next auto-refresh at T=13 (5 min after resume)

4. **Manual refresh coordination**:
   - Auto-refresh scheduled at T=5
   - Manual refresh at T=4
   - Verify timer resets, next auto at T=9

### Mock Response for Testing

```json
{
  "status": "success",
  "data": {
    "rates": [
      {
        "rate_type": "usd",
        "value_in_toman": 700000,
        "label": "دلار آمریکا",
        "timestamp": "2025-12-25T10:00:00.000+03:30",
        "stale": false,
        "change_percent": 0.5,
        "change_direction": "up"
      }
    ],
    "timestamp": "2025-12-25T10:00:00.000+03:30",
    "rates_stale_minutes": 1,
    "stale": false
  }
}
```

---

## Migration Notes

**No migration required** - feature uses existing API as-is.

**Client-side only changes**:
- Add periodic timer in Flutter app
- Add lifecycle management
- No changes to request format or response parsing

**Backward compatibility**: ✅ Full compatibility maintained

---

## Summary

The auto-refresh feature is a **client-side enhancement** that polls the existing public rates endpoint every 5 minutes. No backend modifications required. The existing API contract is sufficient with its 5-minute update cycle and caching headers.

**Key Points**:
- Use existing `GET /api/v1/rates` endpoint
- Poll every 5 minutes when screen active
- Pause polling when backgrounded
- Handle errors gracefully (keep existing data)
- No rate limiting concerns at current scale
