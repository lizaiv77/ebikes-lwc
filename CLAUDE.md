# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

E-Bikes is a sample Salesforce application demonstrating Lightning Web Components (LWC) and Experience Cloud integration. It's a fictitious electric bicycle manufacturer app that manages products and reseller orders.

## Development Commands

### Build and Deployment

- **Deploy to org**: `sf project deploy start`
- **Deploy to specific directory**: `sf project deploy start -d force-app`
- **Deploy Experience Cloud guest profile metadata**: `sf project deploy start --metadata-dir=guest-profile-metadata -w 10`

### Data Management

- **Import sample data**: `sf data tree import -p ./data/sample-data-plan.json`
- **Publish Experience Cloud site**: `sf community publish -n E-Bikes`

### Testing

- **Run all tests**: `npm test`
- **Run unit tests**: `npm run test:unit`
- **Run unit tests in watch mode**: `npm run test:unit:watch`
- **Run unit tests with coverage**: `npm run test:unit:coverage`
- **Run UI tests (UTAM)**:
    1. `npm run test:ui:compile` (compile UTAM page objects)
    2. `npm run test:ui:generate:login` (prepare login info)
    3. `npm run test:ui` (run tests)

### Code Quality

- **Lint code**: `npm run lint`
- **Format code**: `npm run prettier`
- **Verify formatting**: `npm run prettier:verify`

### Org Management

- **Open scratch org**: `sf org open`
- **Create scratch org**: `sf org create scratch -d -f config/project-scratch-def.json -a ebikes`
- **Assign permission sets**:
    - `sf org assign permset -n ebikes`
    - `sf org assign permset -n Walkthroughs`

## Architecture

### Project Structure

- **force-app/main/default/lwc/**: Lightning Web Components
- **force-app/main/default/classes/**: Apex controllers and test classes
- **force-app/main/default/objects/**: Custom objects (Product**c, Order**c, Order_Item**c, Product_Family**c, Manufacturing_Event\_\_e)
- **force-app/main/default/messageChannels/**: Lightning Message Service channels (ProductSelected, ProductsFiltered)
- **force-app/main/default/experiences/**: Experience Cloud site configuration
- **force-app/test/jest-mocks/**: Mock modules for Jest tests
- **force-app/test/utam/**: UI test automation model (UTAM) tests
- **guest-profile-metadata/**: Experience Cloud guest user profile metadata

### Data Model

The application uses custom objects to manage the e-bike business:

- **Product\_\_c**: Individual products with fields like Name, MSRP**c, Category**c, Level**c, Material**c, Picture_URL\_\_c
- **Product_Family\_\_c**: Groups related products
- **Order\_\_c**: Customer orders
- **Order_Item\_\_c**: Line items on orders (junction between Order**c and Product**c)
- **Manufacturing_Event\_\_e**: Platform event for manufacturing data via Pub Sub API

### Key Components

#### Apex Controllers

- **ProductController**: Retrieves products with pagination and filtering (getProducts, getSimilarProducts)
- **OrderController**: Manages order operations
- **PagedResult**: Wrapper class for paginated query results
- **ProductRecordInfoController**: Product record information
- **CommunitiesLandingController**: Experience Cloud landing page logic

#### Lightning Web Components

- **productCard**: Displays individual product details
- **productTile/productTileList**: Grid view of products
- **productFilter**: Filtering UI for product search
- **similarProducts**: Shows related products
- **orderBuilder**: Order creation interface
- **orderItemTile**: Line item display
- **orderStatusPath**: Visual order status indicator
- **accountMap**: Map component for account locations
- **hero/heroDetails**: Landing page hero section
- **createCase**: Case creation form
- **ldsUtils**: Lightning Data Service utility functions
- **errorPanel**: Error handling component
- **placeholder**: Loading state component
- **paginator**: Pagination controls

### Communication Patterns

The app uses Lightning Message Service for component communication:

- **ProductSelected**: Published when a product is selected
- **ProductsFiltered**: Published when product filters change

### Testing Strategy

#### Jest Unit Tests

- LWC components have `__tests__` directories with `.test.js` files
- Use `@salesforce/sfdx-lwc-jest` for LWC-specific testing
- Mock modules defined in `force-app/test/jest-mocks/` for @salesforce/apex, lightning/navigation, lightning/messageService, and lightning/empApi
- Accessibility tests run with @sa11y/jest (configured in jest-sa11y-setup.js)

#### UI Tests with UTAM

- End-to-end tests using UI Test Automation Model
- UTAM page objects compiled from component metadata
- Tests located in `force-app/test/utam/`
- WebdriverIO configuration in wdio.conf.js
- Tests run against active Salesforce org

### Pre-commit Hooks

Husky and lint-staged automatically run on `git commit`:

- Prettier formatting on all relevant files
- ESLint on LWC JavaScript
- Jest tests for changed LWC components (--findRelatedTests)

## Node.js Version

Project uses Node.js 20.15.0 (managed via Volta)

## API Version

Salesforce API version: 63.0

## Experience Cloud

The E-Bikes Experience Cloud site requires:

- Site admin and guest record owner configured in `force-app/main/default/sites/E_Bikes.site-meta.xml`
- Lightning Lite theme activated in Setup > Themes and Branding
- Experience Cloud enabled in the org

## Additional Resources

- Sample data: `data/sample-data-plan.json`
- Code tours available via CodeTour VSCode extension (`.tours/` directory)
- Optional Pub Sub API demo: [ebikes-manufacturing](https://github.com/trailheadapps/ebikes-manufacturing)
