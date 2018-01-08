---
title: "Optionality"
date: 2017-11-22T18:26:59Z
draft: true
---

Here is **some** text

```html
<section id="main">
  <div>
    <h1 id="title">{{ .Title }}</h1>
    {{ range .Data.Pages }}
      {{ .Render "summary"}}
    {{ end }}
  </div>
</section>
```


```go
type ODNRequestContext struct {
	Limiter           *rate.Limiter
	Span              opentracing.Span
	SpecGetter        SpecGetter
	TestWriter        TestWriter
	VariableLookupper VariableLookupper
	Logger            *logrus.Logger
}
```
