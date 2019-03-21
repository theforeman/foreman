# Using BreadcrumbBar with react-router

To make breadcrumbs navigable using react-router, you need to specify the items:

```js
const items = [
    {
      caption: "Hosts",
      to: "/hosts"
    },
    { caption: "Not a link" },
  ];
```

Then pass it as a prop to BreadcrumbBar:

```
<BreadcrumbBar data={{ breadcrumbItems: items }} />
```

Since you will probably use the breadcrumbs in the layout, you can pass the items through the PageLayout:

```
<PageLayout breadcrumbOptions={{ breadcrumbItems: items }}>
// page content here
</PageLayout>
```