---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: home
---

<div style="text-align: center">
  <img src="{{site.baseurl}}/assets/images/pirate-avatar_animated_x3.gif" alt="The Cyber Pirate. Yarrrr!">
</div>

<section>
<ul>
    {% if site.posts[0] %}

        {% for post in site.posts %}
            <li>
                <h2><a href="{{ post.url | prepend: site.baseurl | replace: '//', '/' }}">{{ post.title }}</a></h2>
                <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date_to_string }}</time>
                <p>{{ post.content | strip_html | truncatewords:50 }}</p>
            </li>
        {% endfor %}

    {% endif %}
</ul>
</section>

