# Rize Kültür API – Deployment Guide

## Quick Deploy to Railway

```bash
npm install -g railway
railway login
railway link
railway up
```

## Environment Variables

```env
PORT=3000
MONGODB_URI=your_mongodb_connection
JWT_SECRET=your_jwt_secret
```

## Deploy to Heroku

```bash
heroku create your-app-name
git push heroku main
```

## Testing

```bash
curl https://your-deployed-url/api/health
```
