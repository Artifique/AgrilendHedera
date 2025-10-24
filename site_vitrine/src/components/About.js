import React from 'react';
import aboutImage from './about-image.jpg';

const About = () => {
  return (
    <section id="about" className="about-section">
      <div className="container">
        <h2>Qui sommes-nous ?</h2>
        <div className="about-content">
          <div className="about-text">
            <h3>Connecter la terre à la technologie</h3>
            <p className="about-subtitle">
              Agri-Lend révolutionne la manière dont les agriculteurs vendent leurs produits et dont les acheteurs s'approvisionnent. 
              Notre mission est de créer un écosystème transparent et équitable qui bénéficie à toutes les parties.
            </p>
            <p>
              Grâce à la technologie Hedera, nous assurons des transactions sécurisées et une traçabilité complète, de la ferme à votre porte. 
              Rejoignez-nous dans cette aventure pour une agriculture plus juste, plus transparente et plus durable.
            </p>
            <a href="#contact" className="btn btn-primary">Découvrez comment</a>
          </div>
          <div className="about-image">
            <img src={aboutImage} alt="Agriculture et technologie" />
          </div>
        </div>
      </div>
    </section>
  );
};

export default About;