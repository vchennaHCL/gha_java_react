name: Wiz Scan React

on:
  workflow_dispatch:

permissions:
  id-token: write
  contents: read
  security-events: write
  actions: write
  packages: write

jobs:

  wiz-scan:

    runs-on: xyz-abc-ddd

    timeout-minutes: 60

    steps:

      ####################################################
      # Checkout
      ####################################################

      - name: Checkout Code
        uses: actions/checkout@v4

      ####################################################
      # GHCR Login
      ####################################################

      - name: Login to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ github.token }}

      ####################################################
      # Execute Wiz Scan
      ####################################################

      - name: Run Wiz Scan
        env:
          WIZ_CLIENT_ID: ${{ secrets.WIZ_CLIENT_ID }}
          WIZ_CLIENT_SECRET: ${{ secrets.WIZ_CLIENT_SECRET }}
          WIZ_CNTR_POLICY: "default vuln policy"
        run: |
          chmod +x .github/scripts/run_wiz-scan.sh

          bash .github/scripts/run_wiz-scan.sh \
            "wiz-scan-frontend:1.0" \
            "$GITHUB_WORKSPACE/Dockerfile" \
            "$GITHUB_WORKSPACE"

      ####################################################
      # Upload SARIF
      ####################################################

      - name: Upload SARIF Report
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: results.sarif

          
