import React from 'react';

const Testimonials = () => {
  const testimonials = [
    {
      quote: "Agri-Lend a transformé ma façon de vendre mes récoltes. C'est simple, direct et juste.",
      author: "Madou Coulibaly, Agriculteur"
    },
    {
      quote: "Enfin une plateforme qui garantit la fraîcheur et la traçabilité des produits. Je recommande !",
      author: "Cheick Diallo, Acheteur"
    },
    {
      quote: "Grâce à cette plateforme, j’ai pu vendre ma récolte beaucoup plus rapidement qu’avant. Tout est clair, les échanges sont professionnels, et j’ai enfin accès à des acheteurs que je n’aurais jamais pu atteindre seul",
      author: "Arouna Traoré, Agriculteur"
    }
  ];

  return (
    <section id="testimonials" className="testimonials-section">
      <div className="container">
        <h2>Ce que nos utilisateurs disent</h2>
        <div className="testimonials-grid">
          {testimonials.map((testimonial, index) => (
            <div className="testimonial-card" key={index}>
              <p className="testimonial-quote">"{testimonial.quote}"</p>
              <p className="testimonial-author">- {testimonial.author}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Testimonials;