# Cloud Run example

FROM node:20-alpine

# Create app directory and switch to non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# Create app directory
WORKDIR /usr/src/app

# Copy package files and change ownership
COPY package*.json ./
RUN chown -R nextjs:nodejs /usr/src/app

# Switch to non-root user
USER nextjs

# Install app dependencies
RUN npm ci --omit=dev

# Bundle app source
COPY --chown=nextjs:nodejs . .

# Expose port (Cloud Run will override this)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:' + (process.env.PORT || 8080) + '/', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

CMD [ "npm", "start" ]