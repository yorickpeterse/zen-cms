Currently Zen uses Liquid for all it's front-end business. While Liquid does the job 
reasonable well it has a few big flaws that annoy the crap out of me. First of all it kills
all stack traces and only displays a message such as "Can't convert Array into String".
This is totally useless as you'll have no idea why and where the issue is caused. 

Besides these stack traces Liquid also tends to act unpredictable when dealing with empty
values. It occasionally bitches about not being able to convert A into B even when A is
of a completely different type than Liquid thinks it is.

Because of these issues, regardless whether they are caused by my own code, I'm thinking
of moving away from Liquid. Currently I'm still looking into alternatives but I'm thinking
of experimenting with Radius. Radius basically uses HTML tags and a basic template would
look something like the following:

    <zen:section_entries slug="blog" limit="10" offset="0">
        <article>
            <header>
                <h1>
                    <zen:title />
                </h1>
            </header>
        </article>
    </zen:section_entries>

Radius would offer a few advantages such as proper syntax highlighting for editors not
smart enough to highlight Liquid tags as well as a native key="value" parsing system. I
have no experience with Radius so I might end up choosing an entirely different engine but
so far this seems to be a pretty cool alternative to Liquid.
