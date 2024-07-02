import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: 'mara',
			customCss: [
				'./src/styles/themes.css',
			],

			social: {
				github: 'https://github.com/tracyspells/mara',
			},

			defaultLocale: 'en',
			locales: {
				en: { label: "English" },
			},

			sidebar: [
				{
					label: "Getting Started",
					items: [
						{ label: "Introduction", link: "/getting-started/introduction" },
						{ label: "Installation", link: "/getting-started/installation" },
					],
				},
				{
					label: 'Guides',
					items: [
						// Each item here is one entry in the navigation menu.
						{ label: "Your First Document", link: "/guides/your-first-document/" },
						{ label: "Organizing Documents", link: "/guides/organizing-documents/" },
					],
				},
				{
					label: 'Reference',
					autogenerate: { directory: 'reference' },
				},
			],
		}),
	],
});
